// Directional focus that keeps pinned windows reachable with hjkl.
//
// AeroSpace's --ignore-floating is all-or-nothing: hjkl either skips every
// floating window or none of them. This helper carves out the exception — only
// ids listed in the pin state file are allowed to win a direction. Every other
// case execs the plain AeroSpace command, so a bug here degrades to the previous
// behaviour rather than a dead keybinding.
//
// Targeting a pinned window by id works because Floaty pins by drawing a mirror
// over the original rather than raising it: the original stays an ordinary
// floating window, and AeroSpace window ids are CGWindowIDs, so its rect comes
// straight out of CGWindowList.
import CoreGraphics
import Foundation

let stateFile = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".local/state/aerospace/pinned-windows")

enum Direction: String {
    case left, down, up, right

    /// CGWindowList's y grows downward, so `up` means a smaller y.
    var isHorizontal: Bool { self == .left || self == .right }
    var sign: CGFloat { (self == .left || self == .up) ? -1 : 1 }
}

struct Rect {
    let midX: CGFloat
    let midY: CGFloat
    let minX: CGFloat
    let maxX: CGFloat
    let minY: CGFloat
    let maxY: CGFloat
}

// MARK: - AeroSpace

/// Resolved once so the hot path does not pay for an extra `/usr/bin/env` exec.
let aerospaceBin: String? = ["/opt/homebrew/bin/aerospace", "/usr/local/bin/aerospace"]
    .first { FileManager.default.isExecutableFile(atPath: $0) }

/// Replace this process with the plain AeroSpace focus command.
func fallback(_ direction: Direction) -> Never {
    let args = ["aerospace", "focus", "--ignore-floating", "--wrap-around", direction.rawValue]
    var cArgs: [UnsafeMutablePointer<CChar>?] = args.map { strdup($0) }
    cArgs.append(nil)
    if let bin = aerospaceBin {
        execv(bin, &cArgs)
    }
    execvp("aerospace", &cArgs)
    exit(1)
}

func aerospace(_ args: [String]) -> String? {
    let process = Process()
    if let bin = aerospaceBin {
        process.executableURL = URL(fileURLWithPath: bin)
        process.arguments = args
    } else {
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["aerospace"] + args
    }
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = FileHandle.nullDevice
    do {
        try process.run()
    } catch {
        return nil
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { return nil }
    return String(data: data, encoding: .utf8)
}

// MARK: - Inputs

func pinnedIds() -> Set<Int> {
    guard let contents = try? String(contentsOf: stateFile, encoding: .utf8) else { return [] }
    return Set(
        contents
            .split(whereSeparator: \.isNewline)
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    )
}

struct State {
    let focused: Int
    let tiled: [Int]
    let floating: [Int]
}

/// One `eval` round-trip instead of two `list-windows` invocations — the socket
/// handshake dominates AeroSpace CLI latency. Only the focused workspace is
/// asked for: AeroSpace parks the others off-screen rather than hiding them, so
/// their windows would otherwise pass for legitimate geometry.
let separator = "---SEP---"

func readState() -> State? {
    let expr = """
        list-windows --focused --format "%{window-id}"; \
        echo -- \(separator); \
        list-windows --workspace focused --format "%{window-id}|%{window-layout}"
        """
    guard let out = aerospace(["eval", expr]) else { return nil }
    let sections = out.components(separatedBy: separator)
    guard sections.count == 2,
          let focused = Int(sections[0].trimmingCharacters(in: .whitespacesAndNewlines))
    else { return nil }

    var tiled: [Int] = []
    var floating: [Int] = []
    for line in sections[1].split(whereSeparator: \.isNewline) {
        let parts = line.split(separator: "|", maxSplits: 1)
        guard parts.count == 2, let id = Int(parts[0].trimmingCharacters(in: .whitespaces)) else { continue }
        if parts[1].trimmingCharacters(in: .whitespaces) == "floating" {
            floating.append(id)
        } else {
            tiled.append(id)
        }
    }
    return State(focused: focused, tiled: tiled, floating: floating)
}

func rects(for ids: Set<Int>) -> [Int: Rect] {
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else { return [:] }
    var result: [Int: Rect] = [:]
    for window in list {
        guard let id = window[kCGWindowNumber as String] as? Int, ids.contains(id),
              let bounds = window[kCGWindowBounds as String] as? [String: Any],
              let x = bounds["X"] as? CGFloat, let y = bounds["Y"] as? CGFloat,
              let width = bounds["Width"] as? CGFloat, let height = bounds["Height"] as? CGFloat
        else { continue }
        result[id] = Rect(
            midX: x + width / 2, midY: y + height / 2,
            minX: x, maxX: x + width,
            minY: y, maxY: y + height
        )
    }
    return result
}

// MARK: - Direction

/// Lower is better. Candidates overlapping the focused window on the cross axis
/// beat ones that merely sit in the right half-plane. Returns nil when the
/// candidate is not in `direction` at all.
func score(from origin: Rect, to candidate: Rect, direction: Direction) -> CGFloat? {
    let mainDelta: CGFloat
    let overlaps: Bool
    if direction.isHorizontal {
        mainDelta = (candidate.midX - origin.midX) * direction.sign
        overlaps = candidate.minY < origin.maxY && origin.minY < candidate.maxY
    } else {
        mainDelta = (candidate.midY - origin.midY) * direction.sign
        overlaps = candidate.minX < origin.maxX && origin.minX < candidate.maxX
    }
    guard mainDelta > 0 else { return nil }

    let crossDelta = direction.isHorizontal
        ? abs(candidate.midY - origin.midY)
        : abs(candidate.midX - origin.midX)
    // The overlap bonus has to outrank any on-screen distance, hence a constant
    // larger than the widest plausible desktop.
    return (overlaps ? 0 : 1_000_000) + mainDelta + crossDelta / 1000
}

// MARK: - Main

guard CommandLine.arguments.count == 2,
      let direction = Direction(rawValue: CommandLine.arguments[1])
else {
    FileHandle.standardError.write("usage: aerospace-pin-focus <left|down|up|right>\n".data(using: .utf8)!)
    exit(2)
}

let pinned = pinnedIds()
if pinned.isEmpty { fallback(direction) }

guard let state = readState() else { fallback(direction) }

// A pinned window that was closed, tiled, or left on another workspace is not a
// candidate, which is why the state file never needs cleaning up.
let candidatePins = Set(state.floating).intersection(pinned).subtracting([state.focused])
if candidatePins.isEmpty { fallback(direction) }

let contenders = candidatePins.union(state.tiled).subtracting([state.focused])
let geometry = rects(for: contenders.union([state.focused]))
guard let origin = geometry[state.focused] else { fallback(direction) }

var winner: (id: Int, score: CGFloat)?
for id in contenders {
    guard let rect = geometry[id], let value = score(from: origin, to: rect, direction: direction) else { continue }
    if winner == nil || value < winner!.score { winner = (id, value) }
}

// A tile winning means AeroSpace would have picked it too — hand it back so
// wrap-around stays native.
guard let winner, candidatePins.contains(winner.id) else { fallback(direction) }
_ = aerospace(["focus", "--window-id", String(winner.id)])

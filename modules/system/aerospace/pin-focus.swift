// Directional focus that keeps pinned windows reachable with hjkl.
//
// AeroSpace's `focus` only offers a global `--ignore-floating` switch, so the
// wagon (floating) windows are skipped wholesale — which is what we want for
// the status pills and side panels that make up most of the wagon, and exactly
// what we don't want for a window that is currently pinned in front of
// everything else.
//
// A pinned window is still an ordinary AeroSpace floating window: the pinning
// tool never raises the original, it draws a mirror of the same rect one layer
// above it. So the original stays targetable by window id, and AeroSpace window
// ids are CGWindowIDs — the geometry needed to decide "is the pinned window the
// nearest thing in this direction?" is one CGWindowList call away.
//
// This helper answers only that question. Every other case — no pins, a tile
// wins, anything unexpected — is handed straight back to AeroSpace so the
// native wrap-around and boundary behaviour is preserved.

import CoreGraphics
import Foundation

let stateFile = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".local/state/aerospace/pinned-windows")

enum Direction: String {
    case left, down, up, right

    /// Movement along x for left/right, along y for up/down. CGWindowList's y
    /// grows downward, so `up` means a smaller y.
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

/// Replace this process with the plain AeroSpace focus command. Used for every
/// path this helper does not want to override, so a bug here can never leave a
/// keybinding dead — the worst case is the behaviour we had before.
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
/// handshake dominates AeroSpace CLI latency, so batching the two queries is
/// worth the extra parsing. Windows on other workspaces are deliberately not
/// asked for: AeroSpace parks them off-screen rather than hiding them, so they
/// would otherwise show up as legitimate geometry.
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

/// Lower is better. Windows that overlap the focused window on the cross axis
/// win over ones that merely sit in the right half-plane, which is what makes
/// `alt-l` from a tall column land on the window beside it rather than a distant
/// corner. Returns nil when the candidate is not in `direction` at all.
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
// Nothing pinned is the common case: skip every lookup below and behave exactly
// as the bare keybinding did.
if pinned.isEmpty { fallback(direction) }

guard let state = readState() else { fallback(direction) }

// Only pins that are floating on the focused workspace are in play. A pinned
// window that got tiled, closed, or left behind on another workspace is simply
// not a candidate — no state file cleanup required.
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

// A tile winning means AeroSpace would have picked it too, so let AeroSpace do
// it and keep its wrap-around semantics.
guard let winner, candidatePins.contains(winner.id) else { fallback(direction) }
_ = aerospace(["focus", "--window-id", String(winner.id)])

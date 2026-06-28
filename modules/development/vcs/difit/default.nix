{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.difit;
in
{
  options.modules.development.vcs.difit = {
    enable = mkEnableOption "Enable difit - Git diff viewer with GitHub-like UI";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      # difit normally opens the system default browser via the npm `open`
      # package (which ignores $BROWSER). When running inside a cmux workspace
      # we instead start difit with --no-open and hand the server URL to cmux's
      # built-in browser via `cmux browser open`.
      (pkgs.writeShellScriptBin "difit" ''
        set -uo pipefail

        difit=(${pkgs.nodejs_24}/bin/npx --yes difit@5.0.2)

        # Fall back to plain difit (system browser) when cmux is unavailable or
        # when the user already controls browser behaviour explicitly. Passing
        # --open is the escape hatch to force the system browser.
        if ! command -v cmux >/dev/null 2>&1; then
          exec "''${difit[@]}" "$@"
        fi
        for arg in "$@"; do
          case "$arg" in
            --open | --no-open | --background | -h | --help | -v | --version)
              exec "''${difit[@]}" "$@"
              ;;
          esac
        done

        # Run difit in the foreground (Ctrl+C still stops it) without its own
        # browser, and open the first server URL it reports in cmux's browser.
        opened=0
        "''${difit[@]}" --no-open "$@" | while IFS= read -r line; do
          printf '%s\n' "$line"
          if [ "$opened" -eq 0 ] && [ "''${line#*server started on }" != "$line" ]; then
            url=$(printf '%s' "$line" | grep -oE 'https?://[^[:space:]]+' | head -n1)
            if [ -n "$url" ]; then
              cmux browser open "$url" >/dev/null 2>&1 &
              opened=1
            fi
          fi
        done
      '')
    ];
  };
}

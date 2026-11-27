{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.system.aerospace;
  dotfilesPath = "/Users/${username}/.dotfiles";
  aerospaceCli = "${config.homebrew.prefix or "/opt/homebrew"}/bin/aerospace";
in
{
  options.modules.system.aerospace = {
    enable = mkEnableOption "Enable AeroSpace window manager";
  };

  config = mkIf cfg.enable {
    # Homebrew installation
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "nikitabobko/tap";
          trusted = true;
        }
      ];
      casks = [ "aerospace" ];
    };

    # Configuration files
    home-manager.users.${username} =
      { config, lib, ... }:
      {
        home.file.".config/aerospace/aerospace.toml" = {
          # TOML scopes keys below a table header into that table; prepending
          # keeps the hook top-level whatever tables the template declares.
          text =
            lib.optionalString (config.programs.den.enable or false) ''
              # Added by Nix: den follows declared global floating windows.
              exec-on-workspace-change = ${
                builtins.toJSON [
                  "${config.programs.den.package}/bin/desk"
                  "follow"
                ]
              }

            ''
            + builtins.readFile ./aerospace.toml;

          # Home Manager runs onChange after linkGeneration, only for changed
          # content, and skips it during dry-run. A store symlink swap alone
          # does not notify AeroSpace's file watcher. Activation's PATH lacks
          # /usr/bin and Homebrew, so commands need absolute paths.
          onChange = ''
            if /usr/bin/pgrep -xq AeroSpace; then
              if [ -x ${lib.escapeShellArg aerospaceCli} ]; then
                run ${lib.escapeShellArg aerospaceCli} reload-config \
                  || echo "aerospace: reload-config failed; run aerospace reload-config in your graphical session" >&2
              else
                printf 'aerospace: %s not found; run aerospace reload-config in your graphical session\n' \
                  ${lib.escapeShellArg aerospaceCli} >&2
              fi
            fi
          '';
        };

        # Compiled here rather than built by Nix: pin-focus links against
        # CoreGraphics through the Xcode command line tools, which live outside
        # the store. Without them the hjkl bindings keep working, they just lose
        # the pinned case.
        home.activation.aerospacePinFocus = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          src="${dotfilesPath}/modules/system/aerospace/pin-focus.swift"
          out="$HOME/.local/bin/aerospace-pin-focus"
          if [ ! -x /usr/bin/swiftc ]; then
            echo "aerospace: /usr/bin/swiftc not found - skipping pin-focus build" >&2
          elif [ ! -x "$out" ] || [ "$src" -nt "$out" ]; then
            $DRY_RUN_CMD mkdir -p "$HOME/.local/bin"
            $DRY_RUN_CMD /usr/bin/swiftc -O -o "$out" "$src"
          fi
        '';
      };
  };
}

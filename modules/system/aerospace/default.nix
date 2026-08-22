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
        home.file = {
          ".config/aerospace/aerospace.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/aerospace/aerospace.toml";
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

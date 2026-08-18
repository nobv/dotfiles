{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.system.sketchybar;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.system.sketchybar = {
    enable = mkEnableOption "Highly customizable macOS status bar replacement";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "FelixKratz/formulae";
          trusted = true;
        }
      ];
      brews = [
        { name = "sketchybar"; }
      ];
    };

    # Declarative replacement for `brew services start sketchybar`, so the bar has
    # exactly one owner. Enabling the module starts the bar — a status bar that is
    # installed but not running is the state this module was in for a year.
    launchd.user.agents.sketchybar = {
      serviceConfig = {
        ProgramArguments = [ "/opt/homebrew/bin/sketchybar" ];
        KeepAlive = true;
        RunAtLoad = true;
        EnvironmentVariables = {
          # Required by the formula's own caveat; sketchybar refuses a non-UTF-8 locale.
          LANG = "en_US.UTF-8";
          # launchd hands an agent a bare PATH, and every probe the desk item makes
          # lives outside it: desk (Nix user profile), jq (system Nix profile),
          # aerospace and sketchybar itself (Homebrew). A missing entry here breaks
          # only at runtime — `nix build` stays green either way.
          PATH = concatStringsSep ":" [
            "/etc/profiles/per-user/${username}/bin"
            "/run/current-system/sw/bin"
            "/opt/homebrew/bin"
            "/usr/bin"
            "/bin"
            "/usr/sbin"
            "/sbin"
          ];
        };
      };
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        # The whole directory is linked rather than each file: $PLUGIN_DIR resolves
        # against CONFIG_DIR, so the plugins have to live inside the same tree.
        # config/ is a subdirectory instead of the module root so that default.nix
        # does not end up inside ~/.config/sketchybar.
        #
        # Editing a linked file is live in the repo sense but not on screen —
        # sketchybar has no config watcher, so run `sketchybar --reload` after a
        # change (unlike aerospace.toml, where saving is enough).
        xdg.configFile."sketchybar".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/sketchybar/config";
      };
  };
}

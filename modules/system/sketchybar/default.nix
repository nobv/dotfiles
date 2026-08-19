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
    # The bar sits where the menu bar was, so keeping both would cost the height
    # twice (AeroSpace needs reserved space for sketchybar either way). Hidden is
    # not gone: the pointer at the top edge still reveals it, which is how items
    # not on the bar are reached.
    #
    # Both keys together are "Automatically hide and show the menu bar: Always" in
    # System Settings; _HIHideMenuBar alone leaves it at "On Desktop Only".
    # The second has no nix-darwin option, hence CustomUserPreferences.
    # Takes effect on the next login; `killall SystemUIServer` applies it sooner.
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
    system.defaults.CustomUserPreferences."NSGlobalDomain".AppleMenuBarVisibleInFullscreen = false;

    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "FelixKratz/formulae";
          trusted = true;
        }
      ];
      brews = [
        { name = "sketchybar"; }
        # CPU temperature without root (IOReport, unlike the SMC and
        # powermetrics). homebrew-core, and ahead of nixpkgs: 0.8.2 vs 0.6.1.
        { name = "macmon"; }
        # Next calendar event. Needs Calendar access granted to sketchybar.
        { name = "ical-buddy"; }
      ];
    };

    # Declarative replacement for `brew services start sketchybar`, so the bar has
    # exactly one owner.
    launchd.user.agents.sketchybar = {
      serviceConfig = {
        ProgramArguments = [ "/opt/homebrew/bin/sketchybar" ];
        KeepAlive = true;
        RunAtLoad = true;
        EnvironmentVariables = {
          # Required by the formula's caveat; sketchybar refuses a non-UTF-8 locale.
          LANG = "en_US.UTF-8";
          # launchd gives an agent a bare PATH and every binary the plugins call
          # sits outside it — desk, jq, the Homebrew tools, and battery in
          # /usr/local/bin. A gap here breaks only at runtime: `nix build` stays
          # green, and a plugin run from a shell inherits that shell's PATH, so
          # testing misses it too.
          PATH = concatStringsSep ":" [
            "/etc/profiles/per-user/${username}/bin"
            "/run/current-system/sw/bin"
            "/opt/homebrew/bin"
            "/usr/local/bin"
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
        # Linked as a directory because $PLUGIN_DIR resolves against CONFIG_DIR;
        # config/ is a subdirectory so default.nix stays out of ~/.config.
        # Edits need `sketchybar --reload` — there is no config watcher.
        xdg.configFile."sketchybar".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/sketchybar/config";
      };
  };
}

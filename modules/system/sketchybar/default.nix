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
    # The bar replaces the macOS menu bar rather than sitting alongside it, so the
    # native one has to go: AeroSpace tiles windows over anything that is not the
    # native menu bar, meaning a visible sketchybar needs reserved space
    # (aerospace.toml `gaps.outer.top`), and reserving space for both bars would
    # cost the height twice. Hidden is not gone — moving the pointer to the top
    # edge still reveals the native bar, which is the access path for menu-bar
    # items not aliased into sketchybar.
    #
    # Takes effect on the next login; `killall SystemUIServer` applies it sooner.
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;

    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "FelixKratz/formulae";
          trusted = true;
        }
      ];
      brews = [
        { name = "sketchybar"; }
        # Reads CPU temperature through IOReport, which — unlike the SMC and
        # powermetrics — needs no privileges. Without it the temperature item
        # would have to mirror iStat Menus' rendering, since iStat gets the same
        # numbers from a root daemon this config has no reason to duplicate.
        # From homebrew-core (no tap), and ahead of nixpkgs: 0.8.2 vs 0.6.1.
        { name = "macmon"; }
        # Next calendar event. Reads the macOS calendar store directly — the same
        # source MeetingBar uses (its eventStoreProvider is "MacOS Calendar App",
        # not the Google API), so this replaces MeetingBar's rendering without
        # losing anything. Needs Calendar access granted to sketchybar.
        { name = "ical-buddy"; }
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
          # launchd hands an agent a bare PATH, and every binary the plugins call
          # lives outside it: desk (Nix user profile), jq (system Nix profile),
          # aerospace / macmon / icalBuddy / sketchybar itself (Homebrew), and
          # battery (its installer puts it in /usr/local/bin, not Homebrew's
          # prefix). A missing entry here breaks only at runtime — `nix build`
          # stays green either way, and a plugin started from a shell inherits
          # that shell's PATH, so it does not show up in testing either.
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

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
    toggle.enable = mkEnableOption ''
      sketchybar-toggle, which hides the bar while the pointer is at the top edge
      so the revealed menu bar does not draw over it
    '';
  };

  config = mkIf cfg.enable {
    # The bar sits where the menu bar was; keeping both would cost the height
    # twice. Hidden is not gone — the pointer at the top edge still reveals it.
    #
    # Both keys together are "hide the menu bar: Always"; _HIHideMenuBar alone
    # leaves it at "On Desktop Only". The second has no nix-darwin option, hence
    # CustomUserPreferences. Takes effect on the next login.
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
    system.defaults.CustomUserPreferences."NSGlobalDomain".AppleMenuBarVisibleInFullscreen = false;

    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "FelixKratz/formulae";
          trusted = true;
        }
      ]
      ++ optionals cfg.toggle.enable [
        {
          name = "malpern/tap";
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
      ]
      ++ optionals cfg.toggle.enable [
        { name = "sketchybar-toggle"; }
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
          # Every binary the plugins call sits outside launchd's bare PATH. A gap
          # here breaks only at runtime — `nix build` stays green, and a plugin
          # run from a shell inherits that shell's PATH, so testing misses it too.
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

    # Polls NSEvent.mouseLocation and hides the bar near the top edge, so the
    # revealed menu bar does not land on top of it. Needs no permissions — the
    # location API is readable without Input Monitoring or Accessibility.
    #
    # The default trigger zone of 10px hides the bar well before macOS reveals the
    # menu bar, leaving a band where neither is drawn. 3px lines the two up.
    launchd.user.agents.sketchybar-toggle = mkIf cfg.toggle.enable {
      serviceConfig = {
        ProgramArguments = [
          "/opt/homebrew/bin/sketchybar-toggle"
          "--trigger-zone"
          "3"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        EnvironmentVariables = {
          LANG = "en_US.UTF-8";
          PATH = concatStringsSep ":" [
            "/opt/homebrew/bin"
            "/usr/bin"
            "/bin"
          ];
        };
      };
    };

    home-manager.users.${username} =
      { config, lib, ... }:
      {
        # Linked as a directory because $PLUGIN_DIR resolves against CONFIG_DIR;
        # config/ is a subdirectory so default.nix stays out of ~/.config.
        xdg.configFile."sketchybar".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/sketchybar/config";

        # nix-darwin reloads launchd agents before home-manager links dotfiles,
        # so on first enable the bar starts before ~/.config/sketchybar exists.
        # There is no config watcher either, so this also covers picking up
        # config edits after `switch`.
        home.activation.restartSketchybar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run /bin/launchctl kickstart -k "gui/$(id -u)/org.nixos.sketchybar" || true
        '';
      };
  };
}

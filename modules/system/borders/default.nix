{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.system.borders;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.system.borders = {
    enable = mkEnableOption "JankyBorders, a window border highlight for macOS";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      # Tap is declared by the sketchybar module; both come from FelixKratz.
      brews = [
        { name = "borders"; }
      ];
    };

    # Declarative replacement for `brew services start borders`, matching how
    # sketchybar is run. Reads ~/.config/borders/bordersrc when started with no
    # arguments.
    launchd.user.agents.borders = {
      serviceConfig = {
        ProgramArguments = [ "/opt/homebrew/bin/borders" ];
        KeepAlive = true;
        RunAtLoad = true;
        EnvironmentVariables = {
          LANG = "en_US.UTF-8";
          PATH = concatStringsSep ":" [
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
      { config, lib, ... }:
      {
        xdg.configFile."borders/bordersrc".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/borders/bordersrc";

        # Same ordering trap as sketchybar (FelixKratz's other bar tool, same
        # launchd-before-home-manager race): ~/.config/borders isn't written yet
        # when the agent starts on first enable, so borders sits on its
        # built-in defaults. Restart once writeBoundary has linked the config.
        home.activation.restartBorders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run /bin/launchctl kickstart -k "gui/$(id -u)/org.nixos.borders" || true
        '';
      };
  };
}

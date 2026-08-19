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
      { config, ... }:
      {
        xdg.configFile."borders/bordersrc".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/borders/bordersrc";
      };
  };
}

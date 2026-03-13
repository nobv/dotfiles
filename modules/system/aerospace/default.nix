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
      taps = [ "nikitabobko/tap" ];
      casks = [ "aerospace" ];
    };

    # Configuration files
    home-manager.users.${username} =
      { config, ... }:
      {
        home.file = {
          ".config/aerospace/aerospace.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/system/aerospace/aerospace.toml";

          ".config/aerospace/follow-aqua-voice.sh" = {
            source = ./follow-aqua-voice.sh;
            executable = true;
          };
        };
      };
  };
}

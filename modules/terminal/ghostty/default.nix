{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.terminal.ghostty;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.terminal.ghostty = {
    enable = mkEnableOption "Terminal emulator that uses platform-native UI and GPU acceleration";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "ghostty" ];
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        home.file.".config/ghostty/config".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/terminal/ghostty/config";
      };
  };
}

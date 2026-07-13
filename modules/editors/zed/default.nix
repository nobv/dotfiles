{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.editors.zed;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.editors.zed = {
    enable = mkEnableOption "Zed multiplayer code editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "zed" ];
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        xdg.configFile."zed/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/editors/zed/settings.json";
      };
  };
}

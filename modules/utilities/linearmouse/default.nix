{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.linearmouse;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.utilities.linearmouse = {
    enable = mkEnableOption "LinearMouse mouse and trackpad utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "linearmouse" ];
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        xdg.configFile."linearmouse/linearmouse.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/utilities/linearmouse/linearmouse.json";
      };
  };
}

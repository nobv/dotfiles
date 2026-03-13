{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.workmux;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.development.vcs.workmux = {
    enable = mkEnableOption "Enable workmux";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "raine/workmux/workmux" ];
    };

    home-manager.users.${username} = { config, ... }: {
      home.file.".config/workmux/config.yaml".source =
        config.lib.file.mkOutOfStoreSymlink
          "${dotfilesPath}/modules/development/vcs/workmux/config.yaml";
    };
  };
}

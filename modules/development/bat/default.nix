{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.development.bat;
in
{
  options.modules.development.bat = {
    enable = mkEnableOption "Enable bat (cat replacement) tool";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.bat = {
      enable = true;
    };
  };
}



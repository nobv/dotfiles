{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.postman;
in
{
  options.modules.development.postman = {
    enable = mkEnableOption "Postman API development and testing tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "postman" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.postman;
in
{
  options.modules.tools.postman = {
    enable = mkEnableOption "Postman API development and testing tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "postman" ];
    };
  };
}
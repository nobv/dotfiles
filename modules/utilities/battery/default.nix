{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.battery;
in
{
  options.modules.app.battery = {
    enable = mkEnableOption "Battery health and charging management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "battery" ];
    };
  };
}
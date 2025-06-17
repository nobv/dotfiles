{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.battery;
in
{
  options.modules.utilities.battery = {
    enable = mkEnableOption "Battery health and charging management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "battery" ];
    };
  };
}
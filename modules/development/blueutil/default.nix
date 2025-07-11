{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.blueutil;
in
{
  options.modules.development.blueutil = {
    enable = mkEnableOption "Bluetooth command line utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "blueutil" ];
    };
  };
}
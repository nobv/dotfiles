{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.blueutil;
in
{
  options.modules.tools.blueutil = {
    enable = mkEnableOption "Bluetooth command line utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      brews = [ "blueutil" ];
    };
  };
}
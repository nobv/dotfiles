{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.beeper;
in
{
  options.modules.app.beeper = {
    enable = mkEnableOption "Beeper unified messaging app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "beeper" ];
    };
  };
}
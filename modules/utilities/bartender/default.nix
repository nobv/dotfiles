{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.bartender;
in
{
  options.modules.utilities.bartender = {
    enable = mkEnableOption "Menu bar icon organiser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "bartender" ];
    };
  };
}

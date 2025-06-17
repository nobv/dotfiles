{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.deskpad;
in
{
  options.modules.utilities.deskpad = {
    enable = mkEnableOption "DeskPad virtual monitor for screen sharing";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "deskpad" ];
    };
  };
}
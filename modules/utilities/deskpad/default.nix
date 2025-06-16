{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.deskpad;
in
{
  options.modules.app.deskpad = {
    enable = mkEnableOption "DeskPad virtual monitor for screen sharing";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "deskpad" ];
    };
  };
}
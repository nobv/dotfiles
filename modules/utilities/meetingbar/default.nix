{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.meetingbar;
in
{
  options.modules.utilities.meetingbar = {
    enable = mkEnableOption "Shows the next meeting in the menu bar";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "meetingbar" ];
    };
  };
}

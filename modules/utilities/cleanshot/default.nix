{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.cleanshot;
in
{
  options.modules.utilities.cleanshot = {
    enable = mkEnableOption "Screen capturing tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "cleanshot" ];
    };
  };
}

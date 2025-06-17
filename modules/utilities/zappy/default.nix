{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.zappy;
in
{
  options.modules.utilities.zappy = {
    enable = mkEnableOption "Zappy screenshot and screen recording tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "zappy" ];
    };
  };
}
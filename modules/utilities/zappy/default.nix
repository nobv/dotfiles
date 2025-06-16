{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.zappy;
in
{
  options.modules.app.zappy = {
    enable = mkEnableOption "Zappy screenshot and screen recording tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "zappy" ];
    };
  };
}
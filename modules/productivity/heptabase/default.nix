{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.heptabase;
in
{
  options.modules.productivity.heptabase = {
    enable = mkEnableOption "Heptabase visual knowledge management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "heptabase" ];
    };
  };
}
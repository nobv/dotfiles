{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.amphetamine;
in
{
  options.modules.productivity.amphetamine = {
    enable = mkEnableOption "Amphetamine keep-awake utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Amphetamine" = 937984704;
      };
    };
  };
}
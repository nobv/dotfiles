{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.amphetamine;
in
{
  options.modules.app.amphetamine = {
    enable = mkEnableOption "Amphetamine keep-awake utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Amphetamine" = 937984704;
      };
    };
  };
}
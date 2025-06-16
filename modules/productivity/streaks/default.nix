{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.streaks;
in
{
  options.modules.app.streaks = {
    enable = mkEnableOption "Streaks habit tracking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Streaks" = 963034692;
      };
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.day-one;
in
{
  options.modules.app.day-one = {
    enable = mkEnableOption "Day One journal and diary app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Day One" = 1055511498;
      };
    };
  };
}
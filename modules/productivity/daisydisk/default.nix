{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.daisydisk;
in
{
  options.modules.app.daisydisk = {
    enable = mkEnableOption "DaisyDisk disk usage analyzer";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "DaisyDisk" = 411643860;
      };
    };
  };
}
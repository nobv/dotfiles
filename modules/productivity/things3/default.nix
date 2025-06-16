{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.things3;
in
{
  options.modules.app.things3 = {
    enable = mkEnableOption "Things 3 task management app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Things 3" = 904280696;
      };
    };
  };
}
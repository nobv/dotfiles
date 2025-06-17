{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.things3;
in
{
  options.modules.productivity.things3 = {
    enable = mkEnableOption "Things 3 task management app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Things 3" = 904280696;
      };
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.line;
in
{
  options.modules.app.line = {
    enable = mkEnableOption "LINE messaging app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "LINE" = 539883307;
      };
    };
  };
}
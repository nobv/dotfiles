{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.telegram;
in
{
  options.modules.app.telegram = {
    enable = mkEnableOption "Telegram messaging app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Telegram" = 747648890;
      };
    };
  };
}
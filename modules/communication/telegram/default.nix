{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.communication.telegram;
in
{
  options.modules.communication.telegram = {
    enable = mkEnableOption "Telegram messaging app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Telegram" = 747648890;
      };
    };
  };
}
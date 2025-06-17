{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.communication.messenger;
in
{
  options.modules.communication.messenger = {
    enable = mkEnableOption "Messenger by Facebook";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Messenger" = 1480068668;
      };
    };
  };
}
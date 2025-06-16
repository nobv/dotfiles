{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.messenger;
in
{
  options.modules.app.messenger = {
    enable = mkEnableOption "Messenger by Facebook";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Messenger" = 1480068668;
      };
    };
  };
}
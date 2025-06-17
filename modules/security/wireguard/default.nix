{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.security.wireguard;
in
{
  options.modules.security.wireguard = {
    enable = mkEnableOption "WireGuard VPN client";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "WireGuard" = 1451685025;
      };
    };
  };
}
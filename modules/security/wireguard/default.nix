{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.wireguard;
in
{
  options.modules.tools.wireguard = {
    enable = mkEnableOption "WireGuard VPN client";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "WireGuard" = 1451685025;
      };
    };
  };
}
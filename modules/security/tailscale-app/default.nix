{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.security.tailscale-app;
in
{
  options.modules.security.tailscale-app = {
    enable = mkEnableOption "Mesh VPN based on WireGuard";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "tailscale-app" ];
    };
  };
}

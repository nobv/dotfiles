{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.fd;
in
{
  options.modules.development.fd = {
    enable = mkEnableOption "fd, a simple, fast and user-friendly alternative to find";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fd
    ];
  };
}

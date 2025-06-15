{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.fd;
in
{
  options.modules.tools.fd = {
    enable = mkEnableOption "fd, a simple, fast and user-friendly alternative to find";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
    ];
  };
}

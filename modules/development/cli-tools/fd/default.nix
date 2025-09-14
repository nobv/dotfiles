{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.fd;
in
{
  options.modules.development.cli-tools.fd = {
    enable = mkEnableOption "fd, a simple, fast and user-friendly alternative to find";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fd
    ];
  };
}

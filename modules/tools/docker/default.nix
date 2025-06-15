{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.docker;
in
{
  options.modules.tools.docker = {
    enable = mkEnableOption "Docker development tools and linters";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hadolint
    ];
  };
}

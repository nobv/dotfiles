{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.docker;
in
{
  options.modules.development.docker = {
    enable = mkEnableOption "Docker development tools and linters";
    enableDesktop = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Docker Desktop GUI application";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hadolint
    ];
    
    homebrew = mkIf (cfg.enableDesktop && config.modules.system.homebrew.enable or false) {
      casks = [ "docker-desktop" ];
    };
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.docker;
in
{
  options.modules.tools.docker = {
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
    
    homebrew = mkIf (cfg.enableDesktop && config.modules.tools.homebrew.enable or false) {
      casks = [ "docker" ];
    };
  };
}

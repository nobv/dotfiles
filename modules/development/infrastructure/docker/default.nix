{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.docker;
in
{
  options.modules.development.infrastructure.docker = {
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

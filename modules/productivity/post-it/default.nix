{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.post-it;
in
{
  options.modules.app.post-it = {
    enable = mkEnableOption "Post-it digital sticky notes";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Post-it®" = 1475777828;
      };
    };
  };
}
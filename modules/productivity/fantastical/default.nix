{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.fantastical;
in
{
  options.modules.app.fantastical = {
    enable = mkEnableOption "Fantastical calendar and task management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Fantastical" = 975937182;
      };
    };
  };
}
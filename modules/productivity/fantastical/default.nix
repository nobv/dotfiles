{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.fantastical;
in
{
  options.modules.productivity.fantastical = {
    enable = mkEnableOption "Fantastical calendar and task management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Fantastical" = 975937182;
      };
    };
  };
}
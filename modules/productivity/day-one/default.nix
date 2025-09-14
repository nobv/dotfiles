{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.day-one;
in
{
  options.modules.productivity.day-one = {
    enable = mkEnableOption "Day One journal and diary app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Day One" = 1055511498;
      };
    };
  };
}

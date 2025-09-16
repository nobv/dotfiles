{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.streaks;
in
{
  options.modules.productivity.streaks = {
    enable = mkEnableOption "Streaks habit tracking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Streaks" = 963034692;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.daisydisk;
in
{
  options.modules.productivity.daisydisk = {
    enable = mkEnableOption "DaisyDisk disk usage analyzer";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "DaisyDisk" = 411643860;
      };
    };
  };
}

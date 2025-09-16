{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.post-it;
in
{
  options.modules.productivity.post-it = {
    enable = mkEnableOption "Post-it digital sticky notes";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Post-it®" = 1475777828;
      };
    };
  };
}

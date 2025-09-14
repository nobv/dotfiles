{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.kindle;
in
{
  options.modules.productivity.kindle = {
    enable = mkEnableOption "Kindle e-book reader";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Kindle" = 302584613;
      };
    };
  };
}

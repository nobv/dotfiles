{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.communication.line;
in
{
  options.modules.communication.line = {
    enable = mkEnableOption "LINE messaging app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        LINE = 539883307;
      };
    };
  };
}

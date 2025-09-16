{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.drafts;
in
{
  options.modules.productivity.drafts = {
    enable = mkEnableOption "Drafts quick text capture and processing";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Drafts" = 1435957248;
      };
    };
  };
}

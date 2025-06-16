{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.drafts;
in
{
  options.modules.app.drafts = {
    enable = mkEnableOption "Drafts quick text capture and processing";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Drafts" = 1435957248;
      };
    };
  };
}
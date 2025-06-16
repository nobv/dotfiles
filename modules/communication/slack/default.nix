{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.slack;
in
{
  options.modules.app.slack = {
    enable = mkEnableOption "Slack team communication app";
    source = mkOption {
      type = types.enum [ "cask" "mas" ];
      default = "cask";
      description = "Install source: cask (Homebrew) or mas (Mac App Store)";
    };
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = mkIf (cfg.source == "cask") [ "slack" ];
      masApps = mkIf (cfg.source == "mas") {
        "Slack" = 803453959;
      };
    };
  };
}
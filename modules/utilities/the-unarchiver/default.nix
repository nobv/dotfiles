{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.the-unarchiver;
in
{
  options.modules.app.the-unarchiver = {
    enable = mkEnableOption "The Unarchiver file extraction utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "The Unarchiver" = 425424353;
      };
    };
  };
}
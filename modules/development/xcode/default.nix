{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.xcode;
in
{
  options.modules.tools.xcode = {
    enable = mkEnableOption "Xcode IDE for macOS and iOS development";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Xcode" = 497799835;
      };
    };
  };
}
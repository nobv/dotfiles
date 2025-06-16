{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.yoink;
in
{
  options.modules.app.yoink = {
    enable = mkEnableOption "Yoink improved file drag and drop";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Yoink" = 457622435;
      };
    };
  };
}
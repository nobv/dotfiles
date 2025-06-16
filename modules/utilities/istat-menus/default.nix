{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.istat-menus;
in
{
  options.modules.app.istat-menus = {
    enable = mkEnableOption "iStat Menus system monitoring for menu bar";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "istat-menus" ];
    };
  };
}
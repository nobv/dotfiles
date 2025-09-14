{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.istat-menus;
in
{
  options.modules.utilities.istat-menus = {
    enable = mkEnableOption "iStat Menus system monitoring for menu bar";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "istat-menus" ];
    };
  };
}

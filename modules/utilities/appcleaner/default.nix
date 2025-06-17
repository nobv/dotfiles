{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.appcleaner;
in
{
  options.modules.utilities.appcleaner = {
    enable = mkEnableOption "AppCleaner uninstall utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "appcleaner" ];
    };
  };
}
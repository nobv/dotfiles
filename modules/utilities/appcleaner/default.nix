{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.appcleaner;
in
{
  options.modules.app.appcleaner = {
    enable = mkEnableOption "AppCleaner uninstall utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "appcleaner" ];
    };
  };
}
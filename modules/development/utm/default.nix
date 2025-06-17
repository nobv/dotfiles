{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.utm;
in
{
  options.modules.development.utm = {
    enable = mkEnableOption "UTM virtual machine host for iOS and macOS";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "utm" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.utm;
in
{
  options.modules.tools.utm = {
    enable = mkEnableOption "UTM virtual machine host for iOS and macOS";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "utm" ];
    };
  };
}
{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.system.utm;
in
{
  options.modules.system.utm = {
    enable = mkEnableOption "UTM virtual machine host for iOS and macOS";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "utm" ];
    };
  };
}

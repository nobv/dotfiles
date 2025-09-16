{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.communication.beeper;
in
{
  options.modules.communication.beeper = {
    enable = mkEnableOption "Beeper unified messaging app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "beeper" ];
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.alfred;
in
{
  options.modules.productivity.alfred = {
    enable = mkEnableOption "Application launcher and productivity software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "alfred" ];
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.system.lima;
in
{
  options.modules.system.lima = {
    enable = mkEnableOption "Lima Linux virtual machine manager";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "lima" ];
    };
  };
}

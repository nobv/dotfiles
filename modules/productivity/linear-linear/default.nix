{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.linear-linear;
in
{
  options.modules.productivity.linear-linear = {
    enable = mkEnableOption "Linear project management and issue tracking";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "linear-linear" ];
    };
  };
}

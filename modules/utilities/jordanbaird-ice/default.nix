{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.jordanbaird-ice;
in
{
  options.modules.utilities.jordanbaird-ice = {
    enable = mkEnableOption "Ice menu bar management tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "jordanbaird-ice" ];
    };
  };
}

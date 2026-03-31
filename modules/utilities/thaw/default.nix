{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.thaw;
in
{
  options.modules.utilities.thaw = {
    enable = mkEnableOption "Thaw menu bar management tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "thaw" ];
    };
  };
}

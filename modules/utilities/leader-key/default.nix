{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.leader-key;
in
{
  options.modules.utilities.leader-key = {
    enable = mkEnableOption "Leader Key keyboard shortcuts launcher";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "leader-key" ];
    };
  };
}

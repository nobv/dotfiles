{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.miro;
in
{
  options.modules.productivity.miro = {
    enable = mkEnableOption "Miro collaborative whiteboard platform";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "miro" ];
    };
  };
}

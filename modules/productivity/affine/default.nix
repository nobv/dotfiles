{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.affine;
in
{
  options.modules.productivity.affine = {
    enable = mkEnableOption "Note editor and whiteboard";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "affine" ];
    };
  };
}

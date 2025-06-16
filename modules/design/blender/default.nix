{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.blender;
in
{
  options.modules.app.blender = {
    enable = mkEnableOption "Blender 3D creation suite";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "blender" ];
    };
  };
}
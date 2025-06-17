{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.design.blender;
in
{
  options.modules.design.blender = {
    enable = mkEnableOption "Blender 3D creation suite";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "blender" ];
    };
  };
}
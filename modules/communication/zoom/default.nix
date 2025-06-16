{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.zoom;
in
{
  options.modules.app.zoom = {
    enable = mkEnableOption "Zoom video conferencing app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "zoom" ];
    };
  };
}
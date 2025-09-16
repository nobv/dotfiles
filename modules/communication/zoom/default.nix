{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.communication.zoom;
in
{
  options.modules.communication.zoom = {
    enable = mkEnableOption "Zoom video conferencing app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "zoom" ];
    };
  };
}

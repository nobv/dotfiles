{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.miro;
in
{
  options.modules.app.miro = {
    enable = mkEnableOption "Miro collaborative whiteboard platform";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "miro" ];
    };
  };
}
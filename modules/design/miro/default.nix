{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.design.miro;
in
{
  options.modules.design.miro = {
    enable = mkEnableOption "Miro collaborative whiteboard platform";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "miro" ];
    };
  };
}
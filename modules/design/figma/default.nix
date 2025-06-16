{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.figma;
in
{
  options.modules.app.figma = {
    enable = mkEnableOption "Figma design and prototyping tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "figma" ];
    };
  };
}
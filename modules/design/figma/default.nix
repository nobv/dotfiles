{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.design.figma;
in
{
  options.modules.design.figma = {
    enable = mkEnableOption "Figma design and prototyping tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "figma" ];
    };
  };
}
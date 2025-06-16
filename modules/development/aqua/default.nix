{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.aqua;
in
{
  options.modules.tools.aqua = {
    enable = mkEnableOption "Declarative CLI Version manager";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      brews = [ "aqua" ];
    };
  };
}

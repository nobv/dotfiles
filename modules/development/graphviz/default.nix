{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.graphviz;
in
{
  options.modules.development.graphviz = {
    enable = mkEnableOption "Graph visualization software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "graphviz" ];
    };
  };
}
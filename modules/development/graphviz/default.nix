{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.graphviz;
in
{
  options.modules.tools.graphviz = {
    enable = mkEnableOption "Graph visualization software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      brews = [ "graphviz" ];
    };
  };
}
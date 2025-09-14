{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.media.graphviz;
in
{
  options.modules.media.graphviz = {
    enable = mkEnableOption "Graph visualization software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "graphviz" ];
    };
  };
}

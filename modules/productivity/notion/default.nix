{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.notion;
in
{
  options.modules.app.notion = {
    enable = mkEnableOption "Notion workspace and note-taking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "notion" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.notion;
in
{
  options.modules.productivity.notion = {
    enable = mkEnableOption "Notion workspace and note-taking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "notion" ];
    };
  };
}
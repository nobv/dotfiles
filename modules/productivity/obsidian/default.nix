{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.obsidian;
in
{
  options.modules.productivity.obsidian = {
    enable = mkEnableOption "Obsidian knowledge base and note-taking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "obsidian" ];
    };
  };
}
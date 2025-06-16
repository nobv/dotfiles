{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.obsidian;
in
{
  options.modules.app.obsidian = {
    enable = mkEnableOption "Obsidian knowledge base and note-taking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "obsidian" ];
    };
  };
}
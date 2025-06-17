{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.logseq;
in
{
  options.modules.productivity.logseq = {
    enable = mkEnableOption "Logseq local-first block-based note taking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "logseq" ];
    };
  };
}
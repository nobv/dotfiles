{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.logseq;
in
{
  options.modules.app.logseq = {
    enable = mkEnableOption "Logseq local-first block-based note taking app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "logseq" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.leader-key;
in
{
  options.modules.app.leader-key = {
    enable = mkEnableOption "Leader Key keyboard shortcuts launcher";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "leader-key" ];
    };
  };
}
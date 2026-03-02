{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.terminal.cmux;
in
{
  options.modules.terminal.cmux = {
    enable = mkEnableOption "Ghostty-based terminal with vertical tabs and notifications for AI coding agents";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "cmux" ];
    };
  };
}

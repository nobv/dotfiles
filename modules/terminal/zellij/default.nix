{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.terminal.zellij;
in
{
  options.modules.terminal.zellij = {
    enable = mkEnableOption "Pluggable terminal workspace, with terminal multiplexer as the base feature";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "zellij" ];
    };
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.discord;
in
{
  options.modules.app.discord = {
    enable = mkEnableOption "Discord voice and text chat app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "discord" ];
    };
  };
}
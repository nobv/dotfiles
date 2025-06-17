{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.media.spotify;
in
{
  options.modules.media.spotify = {
    enable = mkEnableOption "Spotify music streaming app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "spotify" ];
    };
  };
}
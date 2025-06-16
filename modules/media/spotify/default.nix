{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.spotify;
in
{
  options.modules.app.spotify = {
    enable = mkEnableOption "Spotify music streaming app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "spotify" ];
    };
  };
}
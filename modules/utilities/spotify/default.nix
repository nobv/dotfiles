{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.spotify;
in
{
  options.modules.utilities.spotify = {
    enable = mkEnableOption "Spotify music streaming app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "spotify" ];
    };
  };
}

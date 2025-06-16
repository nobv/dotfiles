{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.chrome;
in
{
  options.modules.app.chrome = {
    enable = mkEnableOption "Google Chrome web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "google-chrome" ];
    };
  };
}
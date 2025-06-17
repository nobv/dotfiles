{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.browsers.chrome;
in
{
  options.modules.browsers.chrome = {
    enable = mkEnableOption "Google Chrome web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "google-chrome" ];
    };
  };
}
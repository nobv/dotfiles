{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.google-japanese-ime;
in
{
  options.modules.app.google-japanese-ime = {
    enable = mkEnableOption "Google Japanese Input Method Editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "google-japanese-ime" ];
    };
  };
}
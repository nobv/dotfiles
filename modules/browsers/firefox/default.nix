{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.firefox;
in
{
  options.modules.app.firefox = {
    enable = mkEnableOption "Firefox web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "firefox" ];
    };
  };
}
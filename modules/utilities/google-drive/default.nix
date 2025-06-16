{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.google-drive;
in
{
  options.modules.app.google-drive = {
    enable = mkEnableOption "Google Drive cloud storage sync";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "google-drive" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.google-drive;
in
{
  options.modules.utilities.google-drive = {
    enable = mkEnableOption "Google Drive cloud storage sync";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "google-drive" ];
    };
  };
}
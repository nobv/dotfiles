{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.editors.cursor;
in
{
  options.modules.editors.cursor = {
    enable = mkEnableOption "Cursor AI-powered code editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "cursor" ];
    };
  };
}
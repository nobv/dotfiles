{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.editor.cursor;
in
{
  options.modules.editor.cursor = {
    enable = mkEnableOption "Cursor AI-powered code editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "cursor" ];
    };
  };
}
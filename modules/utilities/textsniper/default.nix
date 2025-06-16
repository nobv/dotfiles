{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.textsniper;
in
{
  options.modules.app.textsniper = {
    enable = mkEnableOption "TextSniper OCR text extraction tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "TextSniper" = 1528890965;
      };
    };
  };
}
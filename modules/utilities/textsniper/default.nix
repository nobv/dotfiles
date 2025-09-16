{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.textsniper;
in
{
  options.modules.utilities.textsniper = {
    enable = mkEnableOption "TextSniper OCR text extraction tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "TextSniper" = 1528890965;
      };
    };
  };
}

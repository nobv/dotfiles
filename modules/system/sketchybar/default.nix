{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.sketchybar;
in
{
  options.modules.tools.sketchybar = {
    enable = mkEnableOption "Highly customizable macOS status bar replacement";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      taps = [ "FelixKratz/formulae" ];
      brews = [
        { name = "sketchybar"; }
      ];
    };
  };
}
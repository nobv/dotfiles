{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.system.sketchybar;
in
{
  options.modules.system.sketchybar = {
    enable = mkEnableOption "Highly customizable macOS status bar replacement";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [ { name = "FelixKratz/formulae"; trusted = true; } ];
      brews = [
        { name = "sketchybar"; }
      ];
    };
  };
}

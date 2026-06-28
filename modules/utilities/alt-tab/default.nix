{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.alt-tab;
in
{
  options.modules.utilities.alt-tab = {
    enable = mkEnableOption "Windows-style window switcher for macOS";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "alt-tab" ];
    };
  };
}

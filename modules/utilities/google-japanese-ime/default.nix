{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.google-japanese-ime;
in
{
  options.modules.utilities.google-japanese-ime = {
    enable = mkEnableOption "Google Japanese Input Method Editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "google-japanese-ime" ];
    };
  };
}

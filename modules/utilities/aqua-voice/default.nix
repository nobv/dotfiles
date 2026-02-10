{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.aqua-voice;
in
{
  options.modules.utilities.aqua-voice = {
    enable = mkEnableOption "Speech-to-text system";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "aqua-voice" ];
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.media.brainfm;
in
{
  options.modules.media.brainfm = {
    enable = mkEnableOption "Desktop client for brain.fm";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "brainfm" ];
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.media.finetune;
in
{
  options.modules.media.finetune = {
    enable = mkEnableOption "Per-application volume mixer, equalizer, and audio router";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "finetune" ];
    };
  };
}

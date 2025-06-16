{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.flashspace;
in
{
  options.modules.app.flashspace = {
    enable = mkEnableOption "FlashSpace file management and organization tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "flashspace" ];
    };
  };
}
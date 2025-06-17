{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.flashspace;
in
{
  options.modules.utilities.flashspace = {
    enable = mkEnableOption "FlashSpace file management and organization tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "flashspace" ];
    };
  };
}
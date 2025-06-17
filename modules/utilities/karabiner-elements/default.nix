{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.karabiner-elements;
in
{
  options.modules.utilities.karabiner-elements = {
    enable = mkEnableOption "Karabiner-Elements keyboard customization tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "karabiner-elements" ];
    };
  };
}
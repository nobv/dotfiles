{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.karabiner-elements;
in
{
  options.modules.tools.karabiner-elements = {
    enable = mkEnableOption "Karabiner-Elements keyboard customization tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "karabiner-elements" ];
    };
  };
}
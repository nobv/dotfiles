{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.app.karabiner-elements;
in
{
  options.modules.app.karabiner-elements = {
    enable = mkEnableOption "Karabiner-Elements keyboard customizer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      karabiner-elements
    ];
  };
}

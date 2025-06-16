{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.poe;
in
{
  options.modules.app.poe = {
    enable = mkEnableOption "Poe AI chatbot platform";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "poe" ];
    };
  };
}
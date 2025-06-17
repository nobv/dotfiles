{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.ai.poe;
in
{
  options.modules.ai.poe = {
    enable = mkEnableOption "Poe AI chatbot platform";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "poe" ];
    };
  };
}
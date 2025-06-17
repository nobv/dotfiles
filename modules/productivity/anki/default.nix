{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.anki;
in
{
  options.modules.productivity.anki = {
    enable = mkEnableOption "Anki flashcard learning system";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "anki" ];
    };
  };
}
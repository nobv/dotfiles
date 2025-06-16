{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.anki;
in
{
  options.modules.app.anki = {
    enable = mkEnableOption "Anki flashcard learning system";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "anki" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.term.starship;
  settings = import ./config.nix { lib = lib; };
in
{
  options.modules.term.starship = {
    enable = mkEnableOption "Starship cross-shell prompt with custom configuration";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = settings;
    };
  };
}


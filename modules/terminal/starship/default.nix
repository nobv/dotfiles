{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.terminal.starship;
  settings = import ./config.nix { lib = lib; };
in
{
  options.modules.terminal.starship = {
    enable = mkEnableOption "Starship cross-shell prompt with custom configuration";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = settings;
    };
  };
}


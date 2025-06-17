{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.development.eza;
in
{
  options.modules.development.eza = {
    enable = mkEnableOption "Enable eza (ls replacement) tool";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.eza = {
      enable = true;
    };
  };
}


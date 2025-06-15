{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.tools.eza;
in
{
  options.modules.tools.eza = {
    enable = mkEnableOption "Enable eza (ls replacement) tool";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.eza = {
      enable = true;
    };
  };
}


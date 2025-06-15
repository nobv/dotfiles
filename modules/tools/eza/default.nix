{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.eza;
in
{
  options.modules.tools.eza = {
    enable = mkEnableOption "Enable eza (ls replacement) tool";
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
    };
  };
}


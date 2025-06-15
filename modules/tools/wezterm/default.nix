{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.wezterm;
in
{
  options.modules.tools.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator with custom configuration";
  };

  config = mkIf cfg.enable {
    home.file.".wezterm.lua" = {
      source = ./wezterm.lua;
    };
  };
}

{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.tools.wezterm;
in
{
  options.modules.tools.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator with custom configuration";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.home.file.".wezterm.lua" = {
      source = ./wezterm.lua;
    };
  };
}

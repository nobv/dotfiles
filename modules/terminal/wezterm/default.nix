{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.app.wezterm;
in
{
  options.modules.app.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "wezterm" ];
    };

    home-manager.users.${username}.home.file.".wezterm.lua" = {
      source = ./wezterm.lua;
    };
  };
}

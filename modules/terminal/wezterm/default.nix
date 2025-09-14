{ config
, pkgs
, lib
, username
, ...
}:

with lib;

let
  cfg = config.modules.terminal.wezterm;
in
{
  options.modules.terminal.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "wezterm" ];
    };

    home-manager.users.${username}.home.file.".wezterm.lua" = {
      source = ./wezterm.lua;
    };
  };
}

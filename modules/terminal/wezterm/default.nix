{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.terminal.wezterm;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.terminal.wezterm = {
    enable = mkEnableOption "WezTerm terminal emulator application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "wezterm" ];
    };

    home-manager.users.${username} = { config, ... }: {
      home.file.".wezterm.lua".source =
        config.lib.file.mkOutOfStoreSymlink
          "${dotfilesPath}/modules/terminal/wezterm/wezterm.lua";
    };
  };
}

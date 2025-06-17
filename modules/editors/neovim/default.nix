{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.editors.neovim;
  plugins = (import ./lua/plugins pkgs);
in
{
  options.modules.editors.neovim = {
    enable = mkEnableOption "Neovim text editor with custom configuration";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      xdg.configFile = {
        "nvim/after" = {
          source = ./after;
          recursive = true;
        };

        "nvim/lua" = {
          source = ./lua;
          recursive = true;
        };
      };

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        extraConfig = "source ~/.config/nvim/lua/init.lua";
        plugins = plugins.vimPlugins;
      };
    };
  };
}

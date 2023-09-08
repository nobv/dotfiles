{ config, pkgs, lib, ... }:
let
  plugins = (import ./lua/plugins pkgs);
in
{
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

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = "source ~/.config/nvim/lua/init.lua";
      plugins = plugins.vimPlugins;
    };

  };
}

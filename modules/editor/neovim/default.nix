{ config, pkgs, lib, ... }:

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
      coc = import ./lua/plugins/coc.nix;
      plugins = (import ./lua/plugins pkgs).plugins;
    };

  };
}

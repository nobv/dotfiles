{ config, pkgs, lib, ... }:

{
  home.file.".wezterm.lua" = {
    source = ./wezterm.lua;
  };
}

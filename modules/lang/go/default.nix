{ config, pkgs, lib, ... }:
{
  programs.go = {
    enable = true;
    goPath = "~/src";
  };

  home.packages = with pkgs; [
    gopls
  ];
}

{ config, pkgs, lib, ... }:
{
  programs.go = {
    enable = true;
    goPath = "src";
  };

  # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/go.section.md
  home.packages = with pkgs; [
    gopls
  ];
}

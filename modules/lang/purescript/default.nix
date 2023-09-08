{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    purescript
    spago
    nodePackages.purescript-language-server
    nodePackages.purty
    nodePackages.purs-tidy
  ];
}

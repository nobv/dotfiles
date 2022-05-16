{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    purescript
    nodePackages.purescript-language-server
  ];
}

{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    nodejs
    nodePackages.prettier
  ];
}

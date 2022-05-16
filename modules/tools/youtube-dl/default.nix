{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    youtube-dl
  ];
}

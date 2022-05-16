{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    peco
  ];
}

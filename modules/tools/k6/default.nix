{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    k6
  ];
}

{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    google-cloud-sdk
  ];
}

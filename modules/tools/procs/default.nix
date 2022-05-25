{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    procs
  ];
}

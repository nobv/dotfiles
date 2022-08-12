{ config, pkgs, lib, ... }:
let
  stable = import <nixpkgs-stable> { };
in
{
  home.packages = with pkgs; [
    stable.httpie
  ];
}

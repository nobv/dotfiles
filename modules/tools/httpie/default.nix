{ config, pkgs, lib, ... }:
let
  stable = import <nixpkgs-stable> { };
  unstable = import <nixpkgs-unstable> { };
in
{
  home.packages = with pkgs; [
    stable.httpie
  ];
}

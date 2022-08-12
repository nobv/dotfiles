{ pkgs, lib, ... }:
let
  settings = import ./config.nix { lib = lib; };
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = settings;
  };
}


{ config, pkgs, lib, ... }:

let
  extraConfig = import ./extraConfig.nix;
  aliases = import ./aliases.nix;

  stable = import <nixpkgs-stable> { };
in
{
  home.packages = with pkgs; [
    ghq
    tig
  ];

  programs = {
    git = {
      enable = true;
      aliases = aliases;
      extraConfig = extraConfig;
      ignores = lib.splitString "\n" (builtins.readFile ./.gitignore_global);
      userEmail = "36393714+nobv@users.noreply.github.com";
      userName = "nobv";
      # package = unstable.git;
    };

  };
}

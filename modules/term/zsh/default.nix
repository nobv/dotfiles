{ config, pkgs, lib, ... }:

let
  aliases = import ./aliases.nix;
in
{
  programs = {
    zsh = {
      enable = true;
      autocd = true;
      autosuggestion = {
        enable = true;
      };
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      # dotDir = ".dotfiles/.zsh";
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [ "ll" ];
      };
      initExtra = builtins.readFile ./initExtra;
      shellAliases = aliases;
      profileExtra = builtins.readFile ./profileExtra;
      # plugins = {
      #   "doom" = {
      #       name = 
      #   };
      # };
    };
  };

}



{ config, pkgs, lib, ... }:

{
  programs = {
    zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      # dotDir = ".dotfiles/.zsh";
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [ "ll" ];
      };
      initExtra = builtins.readFile ./initExtra;
      shellAliases = builtins.fromJSON (builtins.readFile ./aliases.json);
      profileExtra = builtins.readFile ./profileExtra;
      # plugins = {
      #   "doom" = {
      #       name = 
      #   };
      # };
    };
  };

}



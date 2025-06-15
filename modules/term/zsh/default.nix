{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.term.zsh;
  aliases = import ./aliases.nix;
in
{
  options.modules.term.zsh = {
    enable = mkEnableOption "Enable Zsh shell with enhanced configuration";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
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



{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.terminal.zsh;
  aliases = import ./aliases.nix;
in
{
  options.modules.terminal.zsh = {
    enable = mkEnableOption "Enable Zsh shell with enhanced configuration";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.zsh = {
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



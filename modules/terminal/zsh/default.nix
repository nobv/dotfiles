{
  config,
  pkgs,
  lib,
  username,
  ...
}:

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
    # Avoid running compinit twice (nix-darwin's /etc/zshrc and this
    # module's ~/.zshrc, with different fpaths): it was rewriting
    # ~/.zcompdump on every shell start, adding ~1s per tmux pane.
    programs.zsh.enableGlobalCompInit = false;

    home-manager.users.${username}.programs.zsh = {
      enable = true;
      enableCompletion = true;
      autocd = true;
      autosuggestion = {
        enable = true;
      };
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
      initContent = builtins.readFile ./.zshrc;
      shellAliases = aliases;
      profileExtra = builtins.readFile ./.zprofile;
    };
  };
}

/*
  enableAutosuggestions = true;
  enableFastSyntaxHighlighting = true;
  enableFzfCompletion = true;
  enableFzfGit = true;
  enableFzfHistory = true;
*/

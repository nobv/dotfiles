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
    # compinit is consolidated onto home-manager's ~/.zshrc (below), which
    # runs after fpath is fully assembled. nix-darwin's own /etc/zshrc calls
    # compinit too, with a differently-ordered fpath (dedup + compaudit's
    # insecure-dir pruning make the two diverge) — every interactive shell
    # was rewriting ~/.zcompdump (3000+ files) twice to reconcile them,
    # adding ~1.1s to every new tmux pane. This only drops the compinit call;
    # pathsToLink, nix-zsh-completions (enableCompletion, untouched) and
    # bashcompinit (enableBashCompletion) still ship system-wide.
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

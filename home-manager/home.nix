{ config, pkgs, lib, ... }:

{
  imports = [
    # ../modules/editor/vscode
    ../modules/checkers
    ../modules/editor/emacs
    ../modules/editor/neovim
    ../modules/editor/vim
    ../modules/font
    ../modules/lang/c
    ../modules/lang/dhall
    ../modules/lang/go
    # ../modules/lang/haskell
    ../modules/lang/javascript
    ../modules/lang/lua
    ../modules/lang/nix
    ../modules/lang/protobuf
    # ../modules/lang/purescript
    #../modules/lang/python
    ../modules/lang/rust
    ../modules/lang/shellscript
    ../modules/term/starship
    ../modules/term/zsh
    # ../modules/tools/aws
    ../modules/tools/aerospace
    ../modules/tools/bat
    ../modules/tools/direnv
    ../modules/tools/docker
    ../modules/tools/eza
    ../modules/tools/fd
    ../modules/tools/fzf
    ../modules/tools/gcp
    ../modules/tools/git
    ../modules/tools/github
    ../modules/tools/gnused
    ../modules/tools/httpie
    ../modules/tools/imagemagic
    ../modules/tools/jq
    ../modules/tools/kubernetes
    ../modules/tools/lf
    ../modules/tools/make
    ../modules/tools/navi
    ../modules/tools/parallel
    ../modules/tools/peco
    ../modules/tools/procs
    ../modules/tools/ripgrep
    ../modules/tools/sops
    ../modules/tools/terraform
    ../modules/tools/tmux
    ../modules/tools/tree
    ../modules/tools/trivy
    ../modules/tools/yt-dlp
    ../modules/tools/wezterm
    ../modules/tools/zotfile
  ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "nobv";
    homeDirectory = "/Users/nobv";

  };


  programs = {
    # emacs = { enable = true; };

    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };


  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];
      allowUnsupportedSystem = true;
      # allowBroken = true;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}

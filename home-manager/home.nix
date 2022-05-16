{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/editor/emacs
    ../modules/editor/vim
    ../modules/lang/go
    ../modules/lang/nix
    ../modules/term/starship
    ../modules/term/zsh
    ../modules/tools/bat
    ../modules/tools/direnv
    ../modules/tools/exa
    ../modules/tools/fzf
    ../modules/tools/git
    ../modules/tools/jq
    ../modules/tools/tmux

  ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "nobv";
    homeDirectory = "/Users/nobv";

    packages = with pkgs; [
      aws
      bats
      clang
      clang-tools
      coreutils
      editorconfig-core-c
      fd
      gh
      ghq
      google-cloud-sdk
      hub
      hunspell

      # hasklig v1.1 doesn't work in VSCode well.
      # For some reason, this PR was closed.
      # https://github.com/NixOS/nixpkgs/pull/135938
      # hasklig
      (nerdfonts.override {
        fonts = [
          "SourceCodePro"
          "Hack"
          "Hasklig"
          "FiraCode"
        ];
      })
      navi
      parallel
      peco
      protobuf
      ripgrep
      shellcheck
      stern
      terraform
      terragrunt
      tig
      tree
      youtube-dl
    ];


  };

  #fonts = { fontconfig = { enable = true; }; };

  programs = {
    # emacs = { enable = true; };


    # comment out until resolive this issue.
    # https://github.com/nix-community/home-manager/issues/1654
    # gh = {
    #   enable = true;
    #   settings = {
    #     git_protocol = "ssh";
    #   };

    # }; 

    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };


  };

  nixpkgs = {
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "vscode"
        # "obsidian"
      ];
      allowUnsupportedSystem = true;
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
  home.stateVersion = "21.11";
}



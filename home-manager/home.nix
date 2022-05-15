{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/lang/nix
    ../modules/editor/emacs
    ../modules/term/starship
    ../modules/term/zsh
    ../modules/tools/git
  ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "nobv";
    homeDirectory = "/Users/nobv";

    packages = with pkgs; [
      aws
      bats
      # black
      # mypy
      clang
      clang-tools
      coreutils
      editorconfig-core-c
      fd
      git
      gh
      ghq
      gopls
      google-cloud-sdk
      hub
      hunspell
      kind
      kubectl
      kubectx
      kustomize
      # lastpass-cli
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
      # nixpkgs-fmt
      navi
      nodejs
      nodePackages.prettier
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
    bat = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    # emacs = { enable = true; };

    exa = { enable = true; };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # comment out until resolive this issue.
    # https://github.com/nix-community/home-manager/issues/1654
    # gh = {
    #   enable = true;
    #   settings = {
    #     git_protocol = "ssh";
    #   };

    # }; 

    go = {
      enable = true;
      goPath = "~/src";
    };

    # Let Home Manager install and manage itself.
    home-manager = {
      enable = true;
    };

    jq = { enable = true; };


    tmux = {
      enable = true;
      baseIndex = 1;
      customPaneNavigationAndResize = true;
      keyMode = "vi";
      prefix = "C-a";
      extraConfig = builtins.readFile ~/.dotfiles/modules/tools/tmux/.tmux.conf;
      historyLimit = 10000;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-boot 'on'
            set -g @continuum-boot-options 'iterm'
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '1'
          '';
        }
      ];
      terminal = "screen-256color";
    };

    vim = { enable = true; };

    # vscode = {
    #   enable = true;
    #   extensions = with pkgs.vscode-extensions; [
    #     # Nix
    #     bbenoist.nix
    #     b4dm4n.vscode-nixpkgs-fmt
    #     # Lisp
    #     # mattn.lisp
    #   ];
    #   userSettings = {
    #     "workbench.colorTheme" = "Default Dark+";
    #     "editor.formatOnSave" = true;
    #   };
    # };


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



{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/nix.nix
    ./modules/emacs.nix
    ./modules/starship
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

    git = {
      enable = true;
      aliases = {
        dv = "difftool --tool=vimdiff --no-prompt";
        lg =
          "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        lga =
          "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        untracked = "ls-files --others --exclude-standard";
        modified = "ls-files --modified";
        add-untracked = "ls-files --others --exclude-standard | xargs git add";
      };
      extraConfig = {
        color = { ui = "auto"; };
        core = {
          editor = "vim";
          # excludesfile = "~/.gitignore_global"
        };
        ghq = { root = "~/src/src"; };
      };
      ignores = [
        # tmux
        ".tmux/plugins/*"
        ".tmux/resurrect/*"

        # emacs
        ".emacs.d/elpa/*"
        ".emacs.d/network-security.data"
        ".emacs.d/backups/*"
        ".emacs.d/recentf"
        ".emacs.d/undohist"
        ".emacs.d/transient/*"
        ".emacs.d/ac-comphist.dat"
        ".emacs.d/auto-save-list/*"
        ".emacs.d/.lsp-session-v1"

        ## spacemacs
        ".spacemacs.d/.spacemacs.env"
        ".spacemacs.d/configs/*"
        "!.spacemacs.d/configs/.gitkeep"

        ## vscode
        ".vscode/extensions/*"
        ".vscode/argv.json"

        ## misc
        "bin/rust-analyzer"
        "conda.yaml"
      ];
      userEmail = "36393714+nobv@users.noreply.github.com";
      userName = "nobv";
    };

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
      extraConfig = builtins.readFile ~/.dotfiles/configs/tmux/.tmux.conf;
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
      initExtra = ''
        # initExtra
        ## history
        setopt hist_ignore_all_dups
        setopt auto_pushd
        setopt pushd_ignore_dups

        ## exports
        export DOTFILES=$HOME/.dotfiles
        export DOOM=$HOME/.emacs.d/doom-emacs/bin
        export PATH=$DOTFILES/bin:$DOOM:$PATH


        ## fzf

        ### history search
        function select-history() {
          BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
          CURSOR=$#BUFFER
        }
        zle -N select-history
        bindkey '^r' select-history
      '';
      shellAliases = {
        # change directory
        home = "cd ~";

        # list
        ls = "exa";
        l = "exa --git --icons -a";
        ll = "exa --long --header --git --icons -a";
        lf = "exa -a | fzf";
        lt = "exa --tree";

        # misc
        reload = "exec $SHELL -l";

      };
      profileExtra = ''
        # for homebrew
        eval $(/opt/homebrew/bin/brew shellenv)

        # for github cli
        eval "$(gh completion -s zsh)"
      '';
      # plugins = {
      #   "doom" = {
      #       name = 
      #   };
      # };
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



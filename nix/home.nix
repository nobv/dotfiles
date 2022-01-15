{ config, pkgs, lib, ... }:

{
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
      # docker
      editorconfig-core-c
      # emacs
      # firefox
      fd
      git
      gh
      ghq
      google-cloud-sdk
      hub
      hunspell
      kind
      kubectl
      kubectx
      kustomize
      lastpass-cli
      (nerdfonts.override {
        fonts = [
          "SourceCodePro"
          "Hack"
          "Hasklig"
          "FiraCode"
        ];
      })
      nixpkgs-fmt
      navi
      nodejs
      parallel
      peco
      protobuf
      ripgrep
      shellcheck
      stern
      terraform
      terragrunt
      tig
      tmux
      tree
      youtube-dl
    ];

    file = {
      ".emacs-profiles.el" = {
        text = builtins.readFile ~.dotfiles/.emacs-profiles.el;
      };

      ".emacs" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "plexus";
          repo = "chemacs2";
          rev = "ef82118824fac2b2363d3171d26acbabe1738326";
          sha256 = "1gg4aa6dxc4k9d78j8mrrhy0mvhqmly7jxby69518xs9njxh00dq";
        };
      };

      ".doom.d" = {
        recursive = true;
        source = builtins.readDir ~./dotfiles/.doom.d;
      };

      "doom-emacs" = {
        recursive = true;
        target = ".emacs.d/doom-emacs";
        source = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "doom-emacs";
          rev = "94c38f289c5bbebd8158dd24ed222c707423a7d5";
          sha256 = "18fmpkspf1fgayg29c18q1ggg9lz68r1g6cqjmj34qi6zcpdr5yf";
        };
      };

      "spacemacs" = {
        recursive = true;
        target = ".emacs.d/spacemacs";
        source = pkgs.fetchFromGitHub {
          owner = "syl20bnr";
          repo = "spacemacs";
          rev = "1541eed6bdaee3e67fc1f9dacf3f21f8494aab68";
          sha256 = "0a0imykbwvq7dga75gzvmx2654l14rfbxc8znpp3q0qqb3m6ldkp";
        };
      };
    };
  };

  fonts = { fontconfig = { enable = true; }; };

  programs = {
    bat = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    emacs = { enable = true; };

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

        ## doom emacs
        ".doom.d/config.el"
        ".doom.d/packages.el"

        ## vscode
        ".vscode/extensions/*"
        ".vscode/argv.json"

        ## misc
        "bin/rust-analyzer"
        "conda.yaml"
      ];
      userEmail = "6e6f6276@gmail.com";
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

    starship = {
      enable = true;
      enableZshIntegration = true;
      # package = 
      settings = {
        format = lib.concatStrings [
          ''
            [┌──────────────────────────────────────────────────────>](bold green)
          ''
          ''
            [│](bold green)[on ☁ Ⓐ ](bold bright-yellow)$aws
          ''
          ''
            [│](bold green)[on ☁ Ⓖ ](bold bright-blue)$gcloud
          ''
          ''
            [│](bold green)[on   ⎈ ](bold red)$kubernetes
          ''
          "[│](bold green)"
          "$username"
          "$hostname"
          "$shlvl"
          "$directory"
          "$vcsh"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status$hg_branch"
          "$docker_context"
          "$package"
          "$cmake"
          "$dart"
          "$deno"
          "$dotnet"
          "$elixir"
          "$elm"
          "$erlang"
          "$golang"
          "$helm"
          "$java"
          "$julia"
          "$kotlin"
          "$nim"
          "$nodejs"
          "$ocaml"
          "$perl"
          "$php"
          "$purescript"
          "$python"
          "$red"
          "$ruby"
          "$rust"
          "$scala"
          "$swift"
          "$terraform"
          "$vlang"
          "$vagrant"
          "$zig"
          "$nix_shell"
          "$conda"
          "$memory_usage"
          "$env_var"
          "$crystal"
          "$custom"
          "$cmd_duration"
          "$line_break"
          "$lua"
          "$jobs"
          "$battery"
          "$time"
          "$status"
          "$shell"
          "[│](bold green)$character "
        ];

        line_break = {
          disabled = true;
        };

        purescript = {
          symbol = "<≡> ";
        };

        aws = {
          format = "[$symbol($profile )(\($region\) )]($style)";
          symbol = "";
          region_aliases = {
            ap-northeast-1 = "🗼";
            ap-southeast-2 = "au";
            us-east-1 = "va";
          };
        };

        gcloud = {
          format = "[$symbol$account(@$domain)(\($project\))(\($region\) )]($style) ";
          symbol = "";
          region_aliases = {
            asia-northeast1 = "🗼";
          };
        };

        character = {
          success_symbol = "[➜](bold green) ";
          error_symbol = "[✗](bold red) ";
        };

        directory = {
          truncation_length = 1;
          truncation_symbol = "…/";
        };

        kubernetes = {
          format = "[$context \($namespace\)]($style) ";
          style = "bold red";
          disabled = false;
          context_aliases = {
            "gke_.*_(?P<cluster>[''\w-]+)" = "gke-$cluster";
          };
        };
      };
    };

    tmux = {
      enable = true;
      extraConfig = "";
      prefix = "C-a";
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
    };

    vim = { enable = true; };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        b4dm4n.vscode-nixpkgs-fmt
      ];
      userSettings = {
        "workbench.colorTheme" = "Default Dark+";
        "editor.formatOnSave" = true;
      };
    };

    zsh = {
      enable = true;
      autocd = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      dotDir = "~/.zsh";
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

        # misc
        reload = "exec $SHELL -l";

      };
      profileExtra = ''
        # for homebrew
        eval $(/opt/homebrew/bin/brew shellenv)

        # for github cli
        eval "$(gh completion -s zsh)"
      '';
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



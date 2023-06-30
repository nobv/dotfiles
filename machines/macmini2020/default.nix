{ config, lib, pkgs, userName, overlays, ... }@inputs:

{
  environment = {
    systemPackages = with pkgs; [
      Morgen
      ThingsHelper
    ];

    darwinConfig = ./default.nix;
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    overlays = overlays;
  };

  services = {
    nix-daemon.enable = true;
  };

  system = {
    stateVersion = 4;

    defaults = {
      dock = {
        autohide = true;
        orientation = "left";
      };

      trackpad = { Clicking = true; };

      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3.0;
        "com.apple.mouse.tapBehavior" = 1;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.nobv = { ... }: {
      home = {
        username = userName;
        stateVersion = "23.05";

      };
      imports = [
        ../../modules/checkers
        ../../modules/editor/emacs
        ../../modules/editor/vim
        ../../modules/editor/neovim
        ../../modules/font
        ../../modules/lang/c
        ../../modules/lang/dhall
        ../../modules/lang/go
        ../../modules/lang/haskell
        ../../modules/lang/javascript
        ../../modules/lang/lua
        ../../modules/lang/nix
        ../../modules/lang/protobuf
        ../../modules/lang/purescript
        ../../modules/lang/python
        ../../modules/lang/rust
        ../../modules/lang/shellscript
        ../../modules/term/starship
        ../../modules/term/zsh
        ../../modules/tools/aws
        ../../modules/tools/bat
        ../../modules/tools/direnv
        ../../modules/tools/docker
        ../../modules/tools/exa
        ../../modules/tools/fd
        ../../modules/tools/fzf
        ../../modules/tools/gcp
        ../../modules/tools/git
        ../../modules/tools/github
        ../../modules/tools/gnused
        ../../modules/tools/httpie
        ../../modules/tools/imagemagic
        ../../modules/tools/jq
        ../../modules/tools/kubernetes
        ../../modules/tools/make
        ../../modules/tools/navi
        ../../modules/tools/parallel
        ../../modules/tools/peco
        ../../modules/tools/procs
        ../../modules/tools/ripgrep
        ../../modules/tools/sops
        ../../modules/tools/terraform
        ../../modules/tools/tmux
        ../../modules/tools/tree
        ../../modules/tools/trivy
        ../../modules/tools/yt-dlp
        ../../modules/tools/zotfile
      ];
    };
  };
}

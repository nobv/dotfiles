{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin.nix
    ./home.nix
  ];

  # Enable modules using actual directory structure paths
  modules = {
    # System tools - lighter setup for desktop
    system = {
      homebrew.enable = true;
      fonts.enable = true;
    };
    
    # Development tools - lighter setup for desktop
    development = {
      tmux.enable = false;  # Less needed on desktop
      docker.enable = false;  # Less Docker development
      kubernetes.enable = false;
      bat.enable = true;
      eza.enable = true;
      fd.enable = true;
      git.enable = true;
      github.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      tree.enable = true;
    };
    
    # Programming languages - lighter development setup
    languages = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      python.enable = false;  # Less Python development
      rust.enable = false;   # Less Rust development
      shellscript.enable = true;
    };
    
    # Text editors - prefer Emacs on desktop
    editors = {
      emacs.enable = true;
      neovim.enable = true;
      vim.enable = true;
      jetbrains.enable = true;
    };
    
    # Terminal configuration
    terminal = {
      starship.enable = true;
      zsh.enable = true;
      wezterm.enable = true;
    };
    
    # Code quality
    checkers.enable = true;
  };
}
{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin.nix
    ./home.nix
  ];

  # Enable modules using the actual option paths defined in module files
  modules = {
    # Core system tools - lighter setup for desktop
    tools = {
      homebrew.enable = true;
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
    lang = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      python.enable = false;  # Less Python development
      rust.enable = false;   # Less Rust development
      shellscript.enable = true;
    };
    
    # Applications
    app = {
      jetbrains.enable = true;
      wezterm.enable = true;
    };
    
    # Text editors - prefer Emacs on desktop
    editor = {
      emacs.enable = true;
      neovim.enable = true;
      vim.enable = true;
    };
    
    # Terminal configuration
    term = {
      starship.enable = true;
      zsh.enable = true;
    };
    
    # Code quality and fonts
    checkers.enable = true;
    font.enable = true;
  };
}
{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin.nix
    ./home.nix
  ];

  # Enable modules using the actual option paths defined in module files
  modules = {
    # Core system tools - full development stack
    tools = {
      homebrew.enable = true;
      tmux.enable = false;
      docker.enable = true;
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
    
    # Programming languages - all programming languages
    lang = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      python.enable = true;
      rust.enable = true;
      shellscript.enable = true;
    };
    
    # Applications
    app = {
      jetbrains.enable = true;
      wezterm.enable = true;
    };
    
    # Text editors - work-focused
    editor = {
      neovim.enable = true;
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

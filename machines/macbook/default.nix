{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin.nix
    ./home.nix
  ];

  # Enable modules using the new option-based structure
  modules = {
    # App modules
    app = {
      jetbrains.enable = true;
    };
    
    # Tool modules - Development-focused setup
    tools = {
      homebrew.enable = true;
      tmux.enable = true;
      wezterm.enable = true;
      docker.enable = true;
      kubernetes.enable = true;
      bat.enable = true;
      eza.enable = true;
      fd.enable = true;
      git.enable = true;
      github.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      tree.enable = true;
    };
    
    # Language modules
    lang = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      python.enable = true;
      rust.enable = true;
      shellscript.enable = true;
    };
    
    # Editor modules
    editor = {
      emacs.enable = false;
      neovim.enable = true;
      vim.enable = true;
    };
    
    # Terminal modules
    term = {
      starship.enable = true;
      zsh.enable = true;
    };
    
    # Other modules  
    checkers.enable = true;
    font.enable = true;
  };
}
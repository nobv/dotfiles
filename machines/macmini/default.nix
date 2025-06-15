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
    
    # Tool modules - lighter setup for desktop
    tools = {
      homebrew.enable = true;
      tmux.enable = false;  # Less needed on desktop
      wezterm.enable = true;
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
    
    # Language modules - lighter development setup
    lang = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      python.enable = false;  # Less Python development
      rust.enable = false;   # Less Rust development
      shellscript.enable = true;
    };
    
    # Editor modules - prefer Emacs on desktop
    editor = {
      emacs.enable = true;
      neovim.enable = true;
      vim.enable = true;
    };
    
    # Terminal modules
    term = {
      starship.enable = true;
      zsh.enable = true;
    };
    
    # Other modules
    font.enable = true;
    checkers.enable = true;
  };
}
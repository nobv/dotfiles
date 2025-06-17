{ config, pkgs, lib, ... }:

{
  imports = [
    ../darwin.nix      # Common Darwin configuration
    ../home.nix        # Common Home Manager configuration
    ./overrides.nix    # MacBook-specific overrides
  ];

  # Enable modules using actual directory structure paths
  modules = {
    # System tools
    system = {
      homebrew.enable = true;
      fonts.enable = true;
    };
    
    # Development tools
    development = {
      tmux.enable = true;
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
    
    # Programming languages
    languages = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      python.enable = true;
      rust.enable = true;
      shellscript.enable = true;
    };
    
    # Text editors
    editors = {
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
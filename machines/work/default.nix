{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin.nix
    ./home.nix
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
      bat.enable = true;
      eza.enable = true;
      fd.enable = true;
      git.enable = true;
      github.enable = true;
      jq.enable = true;
      ripgrep.enable = true;
      tree.enable = true;
      go-task.enable = true;
      gcp.enable = true;
      direnv.enable = true;
      aqua.enable = true;
      peco.enable = true;
      fzf.enable = true;
      fork.enable = true;
    };
    
    # Programming languages
    languages = {
      go.enable = true;
      nodejs.enable = true;
      nix.enable = true;
      rust.enable = true;
      shellscript.enable = true; 
      protobuf.enable = true;
    };
    
    # Text editors
    editors = {
      neovim.enable = true;
      vscode.enable = true;
      jetbrains.enable = true;
    };
    
    # Terminal configuration
    terminal = {
      starship.enable = true;
      zsh.enable = true;
      wezterm.enable = true;
    };
    
    # Security tools
    security = {
      "1password".enable = true;
    };
    
    # Utilities
    utilities = {
      karabiner-elements.enable = true;
      raycast.enable = true;
      flux.enable = true;
    };
    
    # Code quality
    checkers.enable = true;
  };
}

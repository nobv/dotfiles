{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin.nix
    ./home.nix
  ];

  # Enable only the modules we want to test
  modules = {
    editor.vscode.enable = true;
    tools.aerospace.enable = true;
    app.raycast.enable = true;
    tools.homebrew.enable = true;
    
    # Test basic fixed modules
    tools.tree.enable = true;
    tools.ripgrep.enable = true;
    tools.fd.enable = true;
    lang.python.enable = true;
    lang.rust.enable = true;
    lang.nix.enable = true;
    tools.github.enable = true;
  };
}
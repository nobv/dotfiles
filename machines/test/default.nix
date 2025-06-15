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
  };
}
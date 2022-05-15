{ config, pkgs, lib, ... }:

{
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        # Nix
        bbenoist.nix
        b4dm4n.vscode-nixpkgs-fmt
        # Lisp
        # mattn.lisp
      ];
      userSettings = {
        "workbench.colorTheme" = "Default Dark+";
        "editor.formatOnSave" = true;
      };
    };
  };

}




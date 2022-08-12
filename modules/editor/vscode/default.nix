{ config, pkgs, lib, ... }:
let
  settings = import ./settings.nix;
in
{
  home.file = {
    "settings" = {
      target = "Library/Application Support/Code/User/settings.json";
      text = builtins.toJSON settings;
    };
  };


  # programs = {
  #   vscode = {
  #     enable = true;
  #     extensions = with pkgs.vscode-extensions; [
  #       # Nix
  #       bbenoist.nix
  #       b4dm4n.vscode-nixpkgs-fmt
  #       # Lisp
  #       # mattn.lisp
  #     ];
  #     userSettings = {
  #       "workbench.colorTheme" = "Default Dark+";
  #       "editor.formatOnSave" = true;
  #     };
  #   };
  # };

}




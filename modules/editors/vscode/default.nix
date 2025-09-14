{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.editors.vscode;
  settings = import ./settings.nix;
in
{
  options.modules.editors.vscode = {
    enable = mkEnableOption "Enable Visual Studio Code";
  };

  config = mkIf cfg.enable {
    # Homebrew installation
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "visual-studio-code" ];
    };

    # # Configuration files
    # home-manager.users.${username}.home.file = {
    #   "settings" = {
    #     target = "Library/Application Support/Code/User/settings.json";
    #     text = builtins.toJSON settings;
    #   };
    # };

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
  };
}

{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.editors.jetbrains;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.editors.jetbrains = {
    enable = mkEnableOption "JetBrains Toolbox for IDE management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [
        "jetbrains-toolbox"
      ];
    };

    # ideavimrc configuration
    home-manager.users.${username} =
      { config, ... }:
      {
        home.file.".ideavimrc".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/editors/jetbrains/.ideavimrc";
      };
  };
}

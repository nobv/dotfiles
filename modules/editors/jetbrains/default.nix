{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.editors.jetbrains;
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
    home-manager.users.${username}.home.file = {
      ".ideavimrc" = {
        text = builtins.readFile ./.ideavimrc;
      };
    };
  };
}

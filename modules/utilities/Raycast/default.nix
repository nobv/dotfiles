{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.utilities.raycast;
in
{
  options.modules.utilities.raycast = {
    enable = mkEnableOption "Enable Raycast launcher";
  };

  config = mkIf cfg.enable {
    # Homebrew installation
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "raycast" ];
    };

    # Raycast scripts
    home-manager.users.${username}.home.file = {
      ".config/raycast/scripts/flashspace-profile-switcher.sh" = {
        source = ./scripts/flashspace-profile-switcher.sh;
        executable = true;
      };
      ".config/raycast/scripts/float-and-center.sh" = {
        source = ./scripts/float-and-center.sh;
        executable = true;
      };
    };
  };
}
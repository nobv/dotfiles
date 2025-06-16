{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.tools.aerospace;
in
{
  options.modules.tools.aerospace = {
    enable = mkEnableOption "Enable AeroSpace window manager";
  };

  config = mkIf cfg.enable {
    # Homebrew installation
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      taps = [ "nikitabobko/tap" ];
      casks = [ "aerospace" ];
    };

    # Configuration files
    home-manager.users.${username}.home.file.".config/aerospace/aerospace.toml" = {
      source = ./aerospace.toml;
    };
  };
}

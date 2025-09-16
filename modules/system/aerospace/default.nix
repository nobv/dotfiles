{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.system.aerospace;
in
{
  options.modules.system.aerospace = {
    enable = mkEnableOption "Enable AeroSpace window manager";
  };

  config = mkIf cfg.enable {
    # Homebrew installation
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [ "nikitabobko/tap" ];
      casks = [ "aerospace" ];
    };

    # Configuration files
    home-manager.users.${username}.home.file.".config/aerospace/aerospace.toml" = {
      source = ./aerospace.toml;
    };
  };
}

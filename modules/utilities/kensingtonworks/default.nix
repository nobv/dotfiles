{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.kensingtonworks;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.utilities.kensingtonworks = {
    enable = mkEnableOption "KensingtonWorks trackball and mouse settings";
  };

  # No Homebrew cask exists; install the app from Kensington's site by hand.
  config = mkIf cfg.enable {
    home-manager.users.${username} =
      { config, ... }:
      {
        home.file."Library/Preferences/TbwSettings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/utilities/kensingtonworks/TbwSettings.json";
      };
  };
}

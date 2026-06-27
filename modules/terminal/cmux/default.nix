{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.terminal.cmux;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.terminal.cmux = {
    enable = mkEnableOption "Ghostty-based terminal with vertical tabs and notifications for AI coding agents";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "cmux" ];
    };

    home-manager.users.${username} =
      { config, ... }:
      {
        # cmux reads ~/.config/cmux/cmux.json; the repo source is .jsonc so
        # editors treat the comments as valid (JSON with comments).
        home.file.".config/cmux/cmux.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/terminal/cmux/cmux.jsonc";
      };
  };
}

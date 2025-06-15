{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.iTerm2;
in
{
  options.modules.app.iTerm2 = {
    enable = mkEnableOption "iTerm2";
  };

  config = mkIf cfg.enable {
    homebrew = {
      casks = [
        "iterm2"
      ];
    };
  };
}

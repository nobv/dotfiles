{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.terminal.iTerm2;
in
{
  options.modules.terminal.iTerm2 = {
    enable = mkEnableOption "iTerm2";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [
        "iterm2"
      ];
    };
  };
}

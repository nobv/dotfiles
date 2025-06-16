{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app."1password";
in
{
  options.modules.app."1password" = {
    enable = mkEnableOption "1Password password manager";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "1password" ];
    };
  };
}
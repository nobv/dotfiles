{ config, lib, pkgs, username, ... }:

with lib;

let
  cfg = config.modules.tools.direnv;
in
{
  options.modules.tools.direnv = {
    enable = mkEnableOption "direnv shell environment manager";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}

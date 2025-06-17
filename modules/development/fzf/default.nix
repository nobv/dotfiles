{ config, lib, pkgs, username, ... }:

with lib;

let
  cfg = config.modules.development.fzf;
in
{
  options.modules.development.fzf = {
    enable = mkEnableOption "fzf fuzzy finder";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

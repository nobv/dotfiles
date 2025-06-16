{ config, lib, pkgs, username, ... }:

with lib;

let
  cfg = config.modules.tools.fzf;
in
{
  options.modules.tools.fzf = {
    enable = mkEnableOption "fzf fuzzy finder";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

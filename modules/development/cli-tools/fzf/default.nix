{
  config,
  lib,
  pkgs,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.fzf;
in
{
  options.modules.development.cli-tools.fzf = {
    enable = mkEnableOption "fzf fuzzy finder";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

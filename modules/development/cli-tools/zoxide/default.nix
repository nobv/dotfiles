{
  config,
  lib,
  pkgs,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.zoxide;
in
{
  options.modules.development.cli-tools.zoxide = {
    enable = mkEnableOption "zoxide, a smarter cd command";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

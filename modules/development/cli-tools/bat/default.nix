{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.bat;
in
{
  options.modules.development.cli-tools.bat = {
    enable = mkEnableOption "Enable bat (cat replacement) tool";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs.bat = {
      enable = true;
    };
  };
}

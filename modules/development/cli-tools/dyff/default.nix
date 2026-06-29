{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.dyff;
in
{
  options.modules.development.cli-tools.dyff = {
    enable = mkEnableOption "Enable dyff (a diff tool for YAML/JSON files)";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.home.packages = [ pkgs.dyff ];
  };
}

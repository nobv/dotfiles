{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.data-and-protocol.dbeaver-community;
in
{
  options.modules.development.data-and-protocol.dbeaver-community = {
    enable = mkEnableOption "DBeaver Community database management tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "dbeaver-community" ];
    };
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.dbeaver-community;
in
{
  options.modules.tools.dbeaver-community = {
    enable = mkEnableOption "DBeaver Community database management tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "dbeaver-community" ];
    };
  };
}
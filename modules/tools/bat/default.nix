{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.bat;
in
{
  options.modules.tools.bat = {
    enable = mkEnableOption "Enable bat (cat replacement) tool";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
    };
  };
}



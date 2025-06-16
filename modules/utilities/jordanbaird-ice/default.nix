{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.jordanbaird-ice;
in
{
  options.modules.app.jordanbaird-ice = {
    enable = mkEnableOption "Ice menu bar management tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "jordanbaird-ice" ];
    };
  };
}
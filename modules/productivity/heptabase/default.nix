{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.heptabase;
in
{
  options.modules.app.heptabase = {
    enable = mkEnableOption "Heptabase visual knowledge management";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "heptabase" ];
    };
  };
}
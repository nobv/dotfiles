{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.mos;
in
{
  options.modules.utilities.mos = {
    enable = mkEnableOption "Mos smooth scrolling and mouse acceleration control";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "mos" ];
    };
  };
}
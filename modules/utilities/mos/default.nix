{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.mos;
in
{
  options.modules.app.mos = {
    enable = mkEnableOption "Mos smooth scrolling and mouse acceleration control";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "mos" ];
    };
  };
}
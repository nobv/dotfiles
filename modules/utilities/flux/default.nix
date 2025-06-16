{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.flux;
in
{
  options.modules.app.flux = {
    enable = mkEnableOption "f.lux blue light reduction tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "flux" ];
    };
  };
}
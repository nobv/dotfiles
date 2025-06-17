{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.flux;
in
{
  options.modules.utilities.flux = {
    enable = mkEnableOption "f.lux blue light reduction tool";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "flux" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.readdle-spark;
in
{
  options.modules.app.readdle-spark = {
    enable = mkEnableOption "Spark email client by Readdle";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "readdle-spark" ];
    };
  };
}
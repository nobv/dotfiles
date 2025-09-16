{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.communication.readdle-spark;
in
{
  options.modules.communication.readdle-spark = {
    enable = mkEnableOption "Spark email client by Readdle";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "readdle-spark" ];
    };
  };
}

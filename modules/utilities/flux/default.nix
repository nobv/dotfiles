{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.flux;
in
{
  options.modules.utilities.flux = {
    enable = mkEnableOption "Screen colour temperature controller";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "flux-app" ];
    };
  };
}

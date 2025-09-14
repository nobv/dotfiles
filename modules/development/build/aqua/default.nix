{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.build.aqua;
in
{
  options.modules.development.build.aqua = {
    enable = mkEnableOption "Declarative CLI Version manager";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "aqua" ];
    };
  };
}

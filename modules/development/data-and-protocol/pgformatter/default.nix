{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.data-and-protocol.pgformatter;
in
{
  options.modules.development.data-and-protocol.pgformatter = {
    enable = mkEnableOption "PostgreSQL syntax beautifier";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "pgformatter" ];
    };
  };
}

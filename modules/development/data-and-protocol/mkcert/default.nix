{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.data-and-protocol.mkcert;
in
{
  options.modules.development.data-and-protocol.mkcert = {
    enable = mkEnableOption "Simple tool for making locally-trusted development certificates";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "mkcert" ];
    };
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.mkcert;
in
{
  options.modules.development.mkcert = {
    enable = mkEnableOption "Simple tool for making locally-trusted development certificates";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "mkcert" ];
    };
  };
}
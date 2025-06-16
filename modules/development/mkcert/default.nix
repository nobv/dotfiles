{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.mkcert;
in
{
  options.modules.tools.mkcert = {
    enable = mkEnableOption "Simple tool for making locally-trusted development certificates";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      brews = [ "mkcert" ];
    };
  };
}
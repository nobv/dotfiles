{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.httpie;
in
{
  options.modules.app.httpie = {
    enable = mkEnableOption "HTTPie desktop app for API testing";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "httpie" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.httpie;
in
{
  options.modules.utilities.httpie = {
    enable = mkEnableOption "HTTPie desktop app for API testing";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "httpie" ];
    };
  };
}
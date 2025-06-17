{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.httpie;
in
{
  options.modules.development.httpie = {
    enable = mkEnableOption "HTTPie command-line HTTP client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      httpie
    ];
  };
}

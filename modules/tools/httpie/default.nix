{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.httpie;
in
{
  options.modules.tools.httpie = {
    enable = mkEnableOption "HTTPie command-line HTTP client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      httpie
    ];
  };
}

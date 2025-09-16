{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.data-and-protocol.httpie;
in
{
  options.modules.development.data-and-protocol.httpie = {
    enable = mkEnableOption "HTTPie command-line HTTP client";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      httpie
    ];
  };
}

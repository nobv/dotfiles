{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.jq;
in
{
  options.modules.development.jq = {
    enable = mkEnableOption "jq, a lightweight and flexible command-line JSON processor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jq
    ];
  };
}

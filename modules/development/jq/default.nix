{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.jq;
in
{
  options.modules.tools.jq = {
    enable = mkEnableOption "jq, a lightweight and flexible command-line JSON processor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jq
    ];
  };
}

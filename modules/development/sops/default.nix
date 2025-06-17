{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.sops;
in
{
  options.modules.development.sops = {
    enable = mkEnableOption "SOPS secrets management";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
    ];
  };
}

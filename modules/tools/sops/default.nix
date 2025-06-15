{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.sops;
in
{
  options.modules.tools.sops = {
    enable = mkEnableOption "SOPS secrets management";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
    ];
  };
}

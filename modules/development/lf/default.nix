{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.lf;
in
{
  options.modules.development.lf = {
    enable = mkEnableOption "lf terminal file manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lf
    ];
  };
}

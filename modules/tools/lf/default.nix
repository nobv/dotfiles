{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.lf;
in
{
  options.modules.tools.lf = {
    enable = mkEnableOption "lf terminal file manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lf
    ];
  };
}

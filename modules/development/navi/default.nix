{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.navi;
in
{
  options.modules.development.navi = {
    enable = mkEnableOption "navi interactive cheatsheet";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      navi
    ];
  };
}

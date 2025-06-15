{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.navi;
in
{
  options.modules.tools.navi = {
    enable = mkEnableOption "navi interactive cheatsheet";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      navi
    ];
  };
}

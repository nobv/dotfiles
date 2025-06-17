{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.gnused;
in
{
  options.modules.development.gnused = {
    enable = mkEnableOption "GNU sed text stream editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnused
    ];
  };
}

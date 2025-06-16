{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.gnused;
in
{
  options.modules.tools.gnused = {
    enable = mkEnableOption "GNU sed text stream editor";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnused
    ];
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.k6;
in
{
  options.modules.tools.k6 = {
    enable = mkEnableOption "k6 load testing tool";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      k6
    ];
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.procs;
in
{
  options.modules.development.procs = {
    enable = mkEnableOption "procs process viewer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      procs
    ];
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.procs;
in
{
  options.modules.tools.procs = {
    enable = mkEnableOption "procs process viewer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      procs
    ];
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.parallel;
in
{
  options.modules.development.parallel = {
    enable = mkEnableOption "GNU Parallel command-line driven parallelizing utility";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      parallel
    ];
  };
}

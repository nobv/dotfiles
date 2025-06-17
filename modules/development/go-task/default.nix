{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.go-task;
in
{
  options.modules.development.go-task = {
    enable = mkEnableOption "Task runner / simpler Make alternative written in Go";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go-task
    ];
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.go-task;
in
{
  options.modules.tools.go-task = {
    enable = mkEnableOption "Task runner / simpler Make alternative written in Go";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      go-task
    ];
  };
}

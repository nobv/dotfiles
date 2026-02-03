{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.d2;
in
{
  options.modules.productivity.d2 = {
    enable = mkEnableOption "Modern diagram scripting language that turns text to diagrams";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      d2
    ];
  };
}

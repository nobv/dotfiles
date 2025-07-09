{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.productivity.capacities;
in
{
  options.modules.productivity.capacities = {
    enable = mkEnableOption "App to write and organise your ideas";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "capacities" ];
    };
  };
}

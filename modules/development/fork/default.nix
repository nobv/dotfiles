{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.fork;
in
{
  options.modules.tools.fork = {
    enable = mkEnableOption "Fork Git client";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "fork" ];
    };
  };
}
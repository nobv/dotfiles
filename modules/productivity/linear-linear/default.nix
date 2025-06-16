{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.linear-linear;
in
{
  options.modules.app.linear-linear = {
    enable = mkEnableOption "Linear project management and issue tracking";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "linear-linear" ];
    };
  };
}
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.browsers.microsoft-edge;
in
{
  options.modules.browsers.microsoft-edge = {
    enable = mkEnableOption "Microsoft Edge web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "microsoft-edge" ];
    };
  };
}
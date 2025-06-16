{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.microsoft-edge;
in
{
  options.modules.app.microsoft-edge = {
    enable = mkEnableOption "Microsoft Edge web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "microsoft-edge" ];
    };
  };
}
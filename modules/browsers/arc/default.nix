{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.arc;
in
{
  options.modules.app.arc = {
    enable = mkEnableOption "Arc web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "arc" ];
    };
  };
}
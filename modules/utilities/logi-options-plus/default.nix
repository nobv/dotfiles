{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.logi-options-plus;
in
{
  options.modules.app.logi-options-plus = {
    enable = mkEnableOption "Logi Options+ mouse and keyboard customization";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "logi-options+" ];
    };
  };
}
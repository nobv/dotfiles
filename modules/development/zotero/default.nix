{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.zotero;
in
{
  options.modules.development.zotero = {
    enable = mkEnableOption "Zotero reference management software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "zotero" ];
    };
  };
}
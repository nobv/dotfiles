{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.zotero;
in
{
  options.modules.app.zotero = {
    enable = mkEnableOption "Zotero reference management software";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "zotero" ];
    };
  };
}
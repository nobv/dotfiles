{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.deepl;
in
{
  options.modules.app.deepl = {
    enable = mkEnableOption "DeepL translator app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "deepl" ];
    };
  };
}
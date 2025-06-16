{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.japanese-dictionary;
in
{
  options.modules.app.japanese-dictionary = {
    enable = mkEnableOption "Japanese Dictionary by Monokakido";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "辞書 by 物書堂" = 1380563956;
      };
    };
  };
}
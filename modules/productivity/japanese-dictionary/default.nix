{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.productivity.japanese-dictionary;
in
{
  options.modules.productivity.japanese-dictionary = {
    enable = mkEnableOption "Japanese Dictionary by Monokakido";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "辞書 by 物書堂" = 1380563956;
      };
    };
  };
}

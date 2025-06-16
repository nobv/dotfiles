{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.kindle;
in
{
  options.modules.app.kindle = {
    enable = mkEnableOption "Kindle e-book reader";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Kindle" = 302584613;
      };
    };
  };
}
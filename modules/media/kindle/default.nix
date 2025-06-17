{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.media.kindle;
in
{
  options.modules.media.kindle = {
    enable = mkEnableOption "Kindle e-book reader";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Kindle" = 302584613;
      };
    };
  };
}
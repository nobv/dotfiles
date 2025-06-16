{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.app.perplexity;
in
{
  options.modules.app.perplexity = {
    enable = mkEnableOption "Perplexity AI search and answer engine";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      masApps = {
        "Perplexity" = 1875466942;
      };
    };
  };
}
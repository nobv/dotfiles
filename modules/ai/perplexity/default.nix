{ config
, pkgs
, lib
, ...
}:

with lib;

let
  cfg = config.modules.ai.perplexity;
in
{
  options.modules.ai.perplexity = {
    enable = mkEnableOption "Perplexity AI search and answer engine";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Perplexity" = 6714467650;
      };
    };
  };
}

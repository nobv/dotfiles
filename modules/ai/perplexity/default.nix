{
  config,
  pkgs,
  lib,
  ...
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
    # Perplexity is not on the Mac App Store (ADAM ID 6714467650 returns "No
    # apps found") and has no Homebrew cask, so it is installed manually from
    # https://www.perplexity.ai/personal-computer and not managed here.
  };
}

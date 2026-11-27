{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.antigravity-cli;
in
{
  options.modules.ai.antigravity-cli = {
    enable = mkEnableOption "Terminal interface for Antigravity agents";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      # The cask's agy wrapper pins AGY_CLI_DISABLE_AUTO_UPDATE=true, so agy
      # never self-updates; `just apply` (onActivation.upgrade) or
      # `brew upgrade --cask antigravity-cli` is the only update path.
      # Disabling this module zaps ~/.gemini/antigravity-cli (sign-in settings).
      casks = [ "antigravity-cli" ];
    };
  };
}

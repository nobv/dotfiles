{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.ai.codex;
in
{
  options.modules.ai.codex = {
    enable = mkEnableOption "Codex CLI and desktop application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [
        "codex"
        "codex-app"
      ];
    };
  };
}

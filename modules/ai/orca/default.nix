{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.ai.orca;
in
{
  options.modules.ai.orca = {
    enable = mkEnableOption "Orca AI agent orchestrator";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "stablyai/orca";
          trusted = true;
        }
      ];
      casks = [ "stablyai/orca/orca" ];
    };
  };
}

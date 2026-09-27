{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.sbx;
in
{
  options.modules.development.infrastructure.sbx = {
    enable = mkEnableOption "Docker Sandboxes CLI (sbx) - microVM sandboxes";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "docker/tap";
          trusted = true;
        }
      ];
      casks = [ "docker/tap/sbx" ];
    };
  };
}

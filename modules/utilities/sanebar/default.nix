{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.sanebar;
in
{
  options.modules.utilities.sanebar = {
    enable = mkEnableOption "sanebar application";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [
        {
          name = "sane-apps/tap";
          trusted = true;
        }
      ];
      casks = [ "sane-apps/tap/sanebar" ];
    };
  };
}

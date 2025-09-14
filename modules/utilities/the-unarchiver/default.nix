{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.the-unarchiver;
in
{
  options.modules.utilities.the-unarchiver = {
    enable = mkEnableOption "The Unarchiver file extraction utility";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "The Unarchiver" = 425424353;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.yoink;
in
{
  options.modules.utilities.yoink = {
    enable = mkEnableOption "Yoink improved file drag and drop";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Yoink" = 457622435;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.editors.xcode;
in
{
  options.modules.editors.xcode = {
    enable = mkEnableOption "Xcode IDE for macOS and iOS development";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      masApps = {
        "Xcode" = 497799835;
      };
    };
  };
}

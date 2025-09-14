{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.browsers.firefox;
in
{
  options.modules.browsers.firefox = {
    enable = mkEnableOption "Firefox web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "firefox" ];
    };
  };
}

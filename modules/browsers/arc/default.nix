{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.browsers.arc;
in
{
  options.modules.browsers.arc = {
    enable = mkEnableOption "Arc web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "arc" ];
    };
  };
}

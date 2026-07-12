{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.insta360-link-controller;
in
{
  options.modules.utilities.insta360-link-controller = {
    enable = mkEnableOption "Install Insta360 Link Controller";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "insta360-link-controller" ];
    };
  };
}

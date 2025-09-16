{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.utilities.logi-options-plus;
in
{
  options.modules.utilities.logi-options-plus = {
    enable = mkEnableOption "Logi Options+ mouse and keyboard customization";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "logi-options+" ];
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.editors.typora;
in
{
  options.modules.editors.typora = {
    enable = mkEnableOption "Typora markdown editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "typora" ];
    };
  };
}

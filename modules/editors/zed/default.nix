{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.editors.zed;
in
{
  options.modules.editors.zed = {
    enable = mkEnableOption "Zed multiplayer code editor";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "zed" ];
    };
  };
}

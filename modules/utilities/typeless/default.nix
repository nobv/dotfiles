{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.utilities.typeless;
in
{
  options.modules.utilities.typeless = {
    enable = mkEnableOption "AI voice dictation that turns speech into polished text";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "typeless" ];
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.communication.discord;
in
{
  options.modules.communication.discord = {
    enable = mkEnableOption "Discord voice and text chat app";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "discord" ];
    };
  };
}

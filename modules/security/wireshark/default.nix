{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.security.wireshark;
in
{
  options.modules.security.wireshark = {
    enable = mkEnableOption "Wireshark network protocol analyzer";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "wireshark-app" ];
    };
  };
}

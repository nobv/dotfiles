{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.wireshark;
in
{
  options.modules.tools.wireshark = {
    enable = mkEnableOption "Wireshark network protocol analyzer";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "wireshark" ];
    };
  };
}
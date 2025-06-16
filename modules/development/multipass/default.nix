{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.multipass;
in
{
  options.modules.tools.multipass = {
    enable = mkEnableOption "Multipass Ubuntu virtual machine orchestrator";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.tools.homebrew.enable or false) {
      casks = [ "multipass" ];
    };
  };
}
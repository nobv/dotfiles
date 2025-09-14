{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.system.multipass;
in
{
  options.modules.system.multipass = {
    enable = mkEnableOption "Multipass Ubuntu virtual machine orchestrator";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "multipass" ];
    };
  };
}

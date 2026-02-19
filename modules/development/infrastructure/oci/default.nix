{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.oci;
in
{
  options.modules.development.infrastructure.oci = {
    enable = mkEnableOption "Oracle Cloud Infrastructure CLI";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "oci-cli" ];
    };

  };
}

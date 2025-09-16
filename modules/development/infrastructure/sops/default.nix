{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.sops;
in
{
  options.modules.development.infrastructure.sops = {
    enable = mkEnableOption "SOPS secrets management";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
    ];
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.firebase-cli;
in
{
  options.modules.development.infrastructure.firebase-cli = {
    enable = mkEnableOption "Firebase CLI";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      firebase-tools
    ];
  };
}

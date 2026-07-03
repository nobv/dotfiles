{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.openspec;
in
{
  options.modules.development.cli-tools.openspec = {
    enable = mkEnableOption "openspec, an AI-native system for spec-driven development";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openspec
    ];
  };
}

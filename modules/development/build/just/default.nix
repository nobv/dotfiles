{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.build.just;
in
{
  options.modules.development.build.just = {
    enable = mkEnableOption "just command runner";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      just
    ];
  };
}

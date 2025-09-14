{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.parallel;
in
{
  options.modules.development.cli-tools.parallel = {
    enable = mkEnableOption "GNU Parallel command-line driven parallelizing utility";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      parallel
    ];
  };
}

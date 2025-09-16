{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.procs;
in
{
  options.modules.development.cli-tools.procs = {
    enable = mkEnableOption "procs process viewer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      procs
    ];
  };
}

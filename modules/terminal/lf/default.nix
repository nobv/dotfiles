{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.terminal.lf;
in
{
  options.modules.terminal.lf = {
    enable = mkEnableOption "lf terminal file manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lf
    ];
  };
}

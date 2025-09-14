{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.navi;
in
{
  options.modules.development.cli-tools.navi = {
    enable = mkEnableOption "navi interactive cheatsheet";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      navi
    ];
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.ripgrep;
in
{
  options.modules.development.cli-tools.ripgrep = {
    enable = mkEnableOption "ripgrep, a line-oriented search tool that recursively searches directories";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ripgrep
    ];
  };
}

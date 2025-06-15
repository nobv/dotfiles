{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.ripgrep;
in
{
  options.modules.tools.ripgrep = {
    enable = mkEnableOption "ripgrep, a line-oriented search tool that recursively searches directories";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
    ];
  };
}

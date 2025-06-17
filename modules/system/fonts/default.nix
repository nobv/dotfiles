{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.system.fonts;
in
{
  options.modules.system.fonts = {
    enable = mkEnableOption "Enable font module";
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.hack
      nerd-fonts.hasklug
      nerd-fonts.fira-code
    ];
  };
}


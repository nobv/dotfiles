{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.imagemagic;
in
{
  options.modules.tools.imagemagic = {
    enable = mkEnableOption "ImageMagick image manipulation tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      imagemagick
    ];
  };
}

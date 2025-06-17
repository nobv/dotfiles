{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.imagemagic;
in
{
  options.modules.development.imagemagic = {
    enable = mkEnableOption "ImageMagick image manipulation tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      imagemagick
    ];
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.media.imagemagic;
in
{
  options.modules.media.imagemagic = {
    enable = mkEnableOption "ImageMagick image manipulation tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      imagemagick
    ];
  };
}

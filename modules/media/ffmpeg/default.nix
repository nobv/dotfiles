{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.media.ffmpeg;
in
{
  options.modules.media.ffmpeg = {
    enable = mkEnableOption "FFmpeg multimedia framework";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
    ];
  };
}

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.ffmpeg;
in
{
  options.modules.development.ffmpeg = {
    enable = mkEnableOption "FFmpeg multimedia framework";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
    ];
  };
}

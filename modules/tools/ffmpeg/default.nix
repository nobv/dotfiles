{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.tools.ffmpeg;
in
{
  options.modules.tools.ffmpeg = {
    enable = mkEnableOption "FFmpeg multimedia framework";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
    ];
  };
}

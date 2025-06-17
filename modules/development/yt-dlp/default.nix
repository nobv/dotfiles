{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.development.yt-dlp;
in
{
  options.modules.development.yt-dlp = {
    enable = mkEnableOption "yt-dlp, a youtube-dl fork with additional features";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yt-dlp
    ];
  };
}

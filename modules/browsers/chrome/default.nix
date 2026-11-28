{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.browsers.chrome;
in
{
  options.modules.browsers.chrome = {
    enable = mkEnableOption "Google Chrome web browser";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      # Let Chrome update itself so brew bundle won't replace the running app.
      # nix-darwin's cask options don't expose Homebrew's pin flag yet.
      extraConfig = ''
        cask "google-chrome", pin: true
      '';
    };
  };
}

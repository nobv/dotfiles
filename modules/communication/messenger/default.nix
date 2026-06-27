{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.communication.messenger;
in
{
  options.modules.communication.messenger = {
    enable = mkEnableOption "Messenger by Facebook";
  };

  config = mkIf cfg.enable {
    # Messenger's standalone Mac app is discontinued upstream: the Mac App Store
    # build was pulled (ADAM ID 1480068668 returns "No apps found") and the
    # Homebrew cask was disabled on 2025-12-25 (downloads 404). Nothing is
    # installed here; use messenger.com in a browser instead.
  };
}

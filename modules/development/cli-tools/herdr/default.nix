{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.herdr;
in
{
  options.modules.development.cli-tools.herdr = {
    enable = mkEnableOption "herdr, an agent multiplexer that lives in your terminal";
    service.enable = mkEnableOption "herdr server as a keep-alive launchd user agent";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "herdr" ];
    };

    # Declarative mirror of the Homebrew formula's service block (`herdr
    # server`, keep_alive). Use this instead of `brew services start herdr`
    # so the daemon has exactly one owner; a second server exits safely on
    # socket-busy, so overlap is harmless but noisy.
    launchd.user.agents.herdr = mkIf cfg.service.enable {
      serviceConfig = {
        ProgramArguments = [
          "/opt/homebrew/bin/herdr"
          "server"
        ];
        KeepAlive = true;
        RunAtLoad = true;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.cli-tools.herdr;
  dotfilesPath = "/Users/${username}/.dotfiles";
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

    home-manager.users.${username} =
      { config, ... }:
      {
        # Only config.toml is linked — the rest of ~/.config/herdr is runtime
        # state (logs, sockets, session.json). `herdr config reset-keys` and
        # onboarding rewrite the file in place, which replaces the symlink
        # with a plain file; re-run `just nix switch` to restore the link.
        xdg.configFile."herdr/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/development/cli-tools/herdr/config.toml";

        # herdr is a brew binary, so the completion function cannot be built
        # into the Nix profile; generate it at shell start instead.
        programs.zsh.initContent = ''
          command -v herdr >/dev/null 2>&1 && eval "$(herdr completion zsh)"
        '';
      };
  };
}

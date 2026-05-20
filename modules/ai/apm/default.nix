{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.apm;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.ai.apm.enable = mkEnableOption "Agent Package Manager (microsoft/apm)";

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      taps = [ "microsoft/apm" ];
      brews = [ "microsoft/apm/apm" ];
    };

    home-manager.users.${username} =
      { config, lib, ... }:
      {
        home.file = {
          ".apm/apm.yml".source = ./apm.yml;
          ".apm/apm.lock.yaml".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/modules/ai/apm/apm.lock.yaml";
        };

        # Frozen install on every rebuild: read-only, fails the rebuild if
        # apm.yml and apm.lock.yaml drift. Requires `apm` (Homebrew) and
        # `claude` (system) which are activated earlier in the rebuild.
        # Run in a subshell so PATH extensions don't leak into later
        # activation entries (linkGeneration relies on GNU `readlink -e`,
        # which BSD readlink under /usr/bin does not support).
        # /usr/bin: APM bundles GitPython, which shells out to `git`.
        # /run/current-system/sw/bin: where nix-darwin places `claude`.
        home.activation.apmSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          (
            PATH="$PATH:/opt/homebrew/bin:/run/current-system/sw/bin:/usr/bin:/bin"
            if command -v apm >/dev/null && command -v git >/dev/null && command -v claude >/dev/null; then
              $DRY_RUN_CMD apm install --frozen -g
            else
              echo "[apm] apm, claude, or git CLI not found; aborting." >&2
              exit 1
            fi
          ) || exit 1
        '';
      };
  };
}

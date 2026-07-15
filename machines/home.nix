{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  # Common Home Manager configuration shared across all machines
  home-manager = {
    # Fixed-name backup net for a file that drifts to a real one. This is the
    # simple form #50 had to abandon, because Claude's settings.json drifts every
    # activation and a fixed `.backup` then collides with the previous one and
    # aborts. That drifter now carries `force = true` (see the claude-code module),
    # so it's re-linked without a backup and never reaches this path — which frees
    # the fixed name to serve as a graceful net for *unexpected* drift: a file that
    # drifts once is moved to `<file>.backup` and activation proceeds. A file that
    # drifts *repeatedly* collides with its own `.backup` and aborts — the signal
    # to force it too. One backup per file, so nothing accumulates.
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "25.05";
      };

      programs.home-manager.enable = true;
    };
  };
}

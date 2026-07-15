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
    # No activation backups: the only file that drifts to a real one is Claude's
    # settings.json, and it carries `force = true` so activation just re-links it
    # (drift is captured into the repo by `just claude` backport, not a *.backup).
    # A collision on any other file is a genuine surprise — let activation abort
    # loudly and name it, rather than pile up silent timestamped backups.
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

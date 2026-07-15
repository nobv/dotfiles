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
    # Timestamped backups so activation never aborts on an existing *.backup.
    # (backupCommand receives the target path as $1; it is mutually exclusive
    # with backupFileExtension. settings.json can drift to a real file, so each
    # activation needs a unique backup name instead of a fixed ".backup".)
    #
    # Claude Code rewrites its HM-managed symlinks into real files at runtime, so
    # this fires on every activation and the backups would grow without bound.
    # Keep only the newest few per target and prune the rest. Guard an empty or
    # missing target too, so we never `mv` a path that isn't there.
    backupCommand = "${pkgs.writeShellScript "hm-backup" ''
      target="''${1:-}"
      [ -n "$target" ] && [ -e "$target" ] || exit 0
      ${pkgs.coreutils}/bin/mv "$target" "$target.backup.$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)"
      # Names sort chronologically; drop all but the 3 newest backups of this target.
      ${pkgs.findutils}/bin/find "$(${pkgs.coreutils}/bin/dirname "$target")" -maxdepth 1 \
        -name "$(${pkgs.coreutils}/bin/basename "$target").backup.*" \
        | ${pkgs.coreutils}/bin/sort \
        | ${pkgs.coreutils}/bin/head -n -3 \
        | while IFS= read -r old; do ${pkgs.coreutils}/bin/rm -f "$old"; done
    ''}";
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

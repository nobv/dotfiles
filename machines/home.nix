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
    backupCommand = "${pkgs.writeShellScript "hm-backup" ''
      target="$1"
      ${pkgs.coreutils}/bin/mv "$target" "$target.backup.$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)"
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

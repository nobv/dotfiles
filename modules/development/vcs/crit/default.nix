{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.crit;

  # Only these keys are managed; crit itself writes other keys (trust choices etc.).
  managedConfig = builtins.toJSON {
    share_targets = [ ];
    no_update_check = true;
  };
in
{
  options.modules.development.vcs.crit.enable =
    mkEnableOption "Your feedback loop with the agent: review plans and code locally";

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "crit" ];
    };

    home-manager.users.${username} =
      { lib, ... }:
      {
        # Merged instead of linked: crit rewrites the file atomically, which would
        # replace a Home Manager symlink and abort the next switch.
        home.activation.critConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          crit_config="$HOME/.crit.config.json"
          crit_current='{}'
          [ -s "$crit_config" ] && crit_current="$(cat "$crit_config")"
          if crit_merged="$(printf '%s' "$crit_current" \
            | ${pkgs.jq}/bin/jq --argjson managed '${managedConfig}' '. + $managed')"; then
            if [ "$crit_merged" != "$crit_current" ]; then
              $DRY_RUN_CMD sh -c 'umask 077; printf "%s\n" "$1" > "$2"' _ "$crit_merged" "$crit_config"
            fi
          else
            echo "crit: $crit_config is not valid JSON - skipping" >&2
          fi
        '';
      };
  };
}

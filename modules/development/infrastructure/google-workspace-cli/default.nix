{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.infrastructure.google-workspace-cli;
in
{
  options.modules.development.infrastructure.google-workspace-cli = {
    enable = mkEnableOption "Google Workspace CLI (gws)";
  };

  config = mkIf cfg.enable {
    # Not in nixpkgs; install via Homebrew. The `googleworkspace-cli` formula
    # ships the `gws` binary (it conflicts with the separate `gws` formula).
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "googleworkspace-cli" ];
    };

    home-manager.users.${username} =
      { ... }:
      {
        # The default (private) account uses the standard ~/.config/gws.
        # A repo opts into a separate account by adding a `.envrc` with
        # `use gws_profile <name>`: credentials are isolated under
        # ~/.config/gws/profiles/<name>/credentials.enc, and the Google account
        # backing it is chosen at `gws auth login` (consent-screen account
        # picker). The shared client_secret.json is symlinked in so the OAuth
        # client only needs to be set up once.
        programs.direnv.stdlib = mkAfter ''
          use_gws_profile() {
            local dir="''${XDG_CONFIG_HOME:-$HOME/.config}/gws/profiles/$1"
            mkdir -p "$dir"
            [ -f "$HOME/.config/gws/client_secret.json" ] \
              && ln -sfn "$HOME/.config/gws/client_secret.json" "$dir/client_secret.json"
            export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$dir"
          }
        '';
      };
  };
}

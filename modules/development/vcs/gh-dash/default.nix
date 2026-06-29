{
  config,
  lib,
  pkgs,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.development.vcs.gh-dash;
in
{
  options.modules.development.vcs.gh-dash = {
    enable = mkEnableOption "gh-dash GitHub PRs/Issues dashboard TUI";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username}.programs = {
      # Installs the standalone `gh-dash` binary and manages
      # ~/.config/gh-dash/config.yml declaratively when settings are set.
      # With no settings, gh-dash uses its built-in defaults.
      gh-dash.enable = true;

      # Register as a gh extension so `gh dash` works too
      # (requires the github module's programs.gh to be enabled).
      gh.extensions = [ pkgs.gh-dash ];
    };
  };
}

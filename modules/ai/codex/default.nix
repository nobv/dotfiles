{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.codex;
  codexHome = "/Users/${username}/.codex";
in
{
  options.modules.ai.codex = {
    enable = mkEnableOption "Codex CLI and desktop application";

    profiles = mkOption {
      default = { };
      description = ''
        Named Codex profiles. Each is an isolated data boundary via CODEX_HOME
        (~/.config/codex/profiles/<name>) with its own auth.json (file-based
        credentials), history, sessions, and sqlite state. Which account backs
        a profile is chosen at `codex login`, so profiles authenticate
        independently and can run simultaneously. Note `codex --profile` is
        unrelated: it layers config.toml sections and never switches accounts.

        Unlike claude-code the user config is not repo-tracked — codex and the
        ChatGPT desktop app rewrite ~/.codex/config.toml live (MCP servers,
        [projects] trust levels), so each profile symlinks the LIVE shared
        files (config.toml, AGENTS.md, prompts/, rules/) from ~/.codex. Only
        the read-only system layer (/etc/codex/config.toml) is tracked.

        Per-repo switching is usually better done with a `.envrc` containing
        `use codex_profile <name>` (no entry here needed). Declare a profile
        here only when you want a git-tracked, always-present alias.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              configDir = mkOption {
                type = types.str;
                default = "/Users/${username}/.config/codex/profiles/${name}";
                description = "Absolute CODEX_HOME for this profile.";
              };

              aliasName = mkOption {
                type = types.str;
                default = "cx-${name}";
                description = "Shell alias that launches Codex for this profile.";
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [
        "codex"
        "codex-app"
      ];
    };

    # Codex reads /etc/codex/config.toml as its lowest-priority layer and never
    # writes to it, so unlike ~/.codex/config.toml it is safe to track here.
    # The user config stays live/machine-local and still wins, so /statusline
    # can override these on top.
    # Embed the file in the generated /etc closure.  `source = ./config.toml`
    # leaves /etc/static pointing at the flake's source-store path, which may
    # be garbage-collected independently of the active system generation.
    environment.etc."codex/config.toml".text = builtins.readFile ./config.toml;

    home-manager.users.${username} =
      { config, lib, ... }:
      let
        # Shared files come from the LIVE ~/.codex (machine-local, rewritten
        # by codex itself), not from the repo — see the profiles description.
        mkCodexLink = path: config.lib.file.mkOutOfStoreSymlink "${codexHome}/${path}";
        # home.file keys are relative to $HOME; profile config dirs live under it.
        homeRel = profile: removePrefix "/Users/${username}/" profile.configDir;
      in
      {
        home.file = mkMerge (
          mapAttrsToList (_: profile: {
            # Codex rewrites config.toml at runtime (atomic replace turns the
            # symlink into a real file), so like Claude's settings.json it
            # collides on every activation. force = true re-links without a
            # backup; profile-local drift (e.g. [projects] trust written in a
            # profile session) is intentionally discarded — shared config
            # lives in ~/.codex/config.toml (see machines/home.nix).
            "${homeRel profile}/config.toml" = {
              source = mkCodexLink "config.toml";
              force = true;
            };
            "${homeRel profile}/AGENTS.md".source = mkCodexLink "AGENTS.md";
            "${homeRel profile}/prompts".source = mkCodexLink "prompts";
            "${homeRel profile}/rules".source = mkCodexLink "rules";
          }) cfg.profiles
        );

        # Activation tolerates dangling out-of-store symlinks, but codex fails
        # at runtime when it mkdirs through a dangling directory link on a
        # fresh machine — ensure the shared target dirs exist.
        home.activation = mkIf (cfg.profiles != { }) {
          ensureCodexSharedDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p ${codexHome}/prompts ${codexHome}/rules
          '';
        };

        # `cx-<name>` launches the CLI, `cx-<name>-app` the desktop app, each
        # with that profile's isolated CODEX_HOME (-n: new instance, so two
        # accounts can run side by side).
        programs.zsh.shellAliases = mkMerge (
          mapAttrsToList (_: profile: {
            ${profile.aliasName} = "CODEX_HOME=${profile.configDir} codex";
            "${profile.aliasName}-app" = "open -n -a Codex --env CODEX_HOME=${profile.configDir}";
          }) cfg.profiles
        );

        # `codex-app` opens the desktop app honoring the current CODEX_HOME
        # (e.g. inside a direnv-activated profile repo); default home otherwise.
        programs.zsh.initContent = ''
          codex-app() {
            if [ -n "''${CODEX_HOME:-}" ]; then
              open -n -a Codex --env CODEX_HOME="$CODEX_HOME"
            else
              open -n -a Codex
            fi
          }
        '';

        # direnv helper: a repo's `.envrc` with `use codex_profile <name>`
        # isolates Codex data (auth/history/sessions/state) under
        # ~/.config/codex/profiles/<name>, while sharing the live config.toml
        # / AGENTS.md / prompts / rules from ~/.codex.
        programs.direnv.stdlib = mkAfter ''
          use_codex_profile() {
            local dir="''${XDG_CONFIG_HOME:-$HOME/.config}/codex/profiles/$1"
            mkdir -p "$dir" "$HOME/.codex/prompts" "$HOME/.codex/rules"
            ln -sfn "$HOME/.codex/config.toml" "$dir/config.toml"
            ln -sfn "$HOME/.codex/AGENTS.md" "$dir/AGENTS.md"
            ln -sfn "$HOME/.codex/prompts" "$dir/prompts"
            ln -sfn "$HOME/.codex/rules" "$dir/rules"
            export CODEX_HOME="$dir"
          }
        '';
      };
  };
}

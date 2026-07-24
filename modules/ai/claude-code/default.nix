{
  config,
  pkgs,
  lib,
  username,
  ...
}:

with lib;

let
  cfg = config.modules.ai.claude-code;
  dotfilesPath = "/Users/${username}/.dotfiles";
in
{
  options.modules.ai.claude-code = {
    enable = mkEnableOption "Claude Code CLI and dotfiles";

    settingsSource = mkOption {
      type = types.str;
      default = "modules/ai/claude-code/settings.json";
      description = ''
        Path to settings.json, relative to the dotfiles repository root.
        Defaults to the shared settings; override per-machine (in the machine's
        default.nix) to point at a machine-local (git-ignored) settings.json.
      '';
    };

    profiles = mkOption {
      default = { };
      description = ''
        Named Claude Code profiles. Each is an isolated data boundary via
        CLAUDE_CONFIG_DIR (~/.config/claude/profiles/<name>) with its own history,
        projects, and credentials. Which account backs a profile is chosen at
        `/login` — the same private account can back several profiles (e.g. an
        isolated client repo you must use a personal account for). On macOS each
        config dir gets its own Keychain entry (the service name is namespaced by
        a sha256 of the path), so profiles authenticate independently and can run
        simultaneously.

        Per-repo switching is usually better done with a `.envrc` containing
        `use claude_profile <name>` (no entry here needed). Declare a profile here
        only when you want a git-tracked, always-present alias + settings symlink.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              configDir = mkOption {
                type = types.str;
                default = "/Users/${username}/.config/claude/profiles/${name}";
                description = "Absolute CLAUDE_CONFIG_DIR for this profile.";
              };

              settingsSource = mkOption {
                type = types.str;
                default = "modules/ai/claude-code/settings.json";
                description = "Path to this profile's settings.json, relative to the repo root.";
              };

              aliasName = mkOption {
                type = types.str;
                default = "cc-${name}";
                description = "Shell alias that launches Claude Code for this profile.";
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];

    environment.systemPackages = with pkgs; [
      claude-code
      cship
    ];

    home-manager.users.${username} =
      { config, lib, ... }:
      let
        mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
        sharedClaudeMd = "modules/ai/claude-code/CLAUDE.md";
        # home.file keys are relative to $HOME; profile config dirs live under it.
        homeRel = profile: removePrefix "/Users/${username}/" profile.configDir;
      in
      {
        home.file = mkMerge (
          [
            {
              # Claude rewrites this into a real file at runtime, so it collides
              # with the symlink on every activation. force = true re-links it
              # without a backup; live drift is captured by `just claude` backport,
              # not a *.backup pile (see machines/home.nix — no backupCommand).
              ".claude/settings.json" = {
                source = mkSymlink cfg.settingsSource;
                force = true;
              };
              ".claude/CLAUDE.md".source = mkSymlink sharedClaudeMd;
              ".claude/commands/difit.md".source = mkSymlink "modules/ai/claude-code/commands/difit.md";
              # difit/difit-review skills now come from upstream via apm
              # (yoshiko-pg/difit/skills/*); see modules/ai/apm/apm.yml.
              ".config/cship.toml".source = mkSymlink "modules/ai/claude-code/cship.toml";
            }
          ]
          ++ (mapAttrsToList (_: profile: {
            # Same as ~/.claude/settings.json: force the re-link so a profile whose
            # settings.json has drifted to a real file doesn't abort activation.
            "${homeRel profile}/settings.json" = {
              source = mkSymlink profile.settingsSource;
              force = true;
            };
            "${homeRel profile}/CLAUDE.md".source = mkSymlink sharedClaudeMd;
            # Share user-scope skills + commands (~/.claude/{skills,commands}) so
            # profiles also see them; otherwise personal/apm skills and custom
            # slash commands are invisible under a profile.
            "${homeRel profile}/skills".source =
              config.lib.file.mkOutOfStoreSymlink "/Users/${username}/.claude/skills";
            "${homeRel profile}/commands".source =
              config.lib.file.mkOutOfStoreSymlink "/Users/${username}/.claude/commands";
          }) cfg.profiles)
        );

        # Profiles created ad hoc by `use claude_profile` are deliberately not
        # declared in `profiles` above — their names identify workplaces and this
        # repo is public. Re-establish their links by scanning the profiles root
        # instead, so the shared config survives without naming anything here.
        # Claude rewrites settings.json atomically, replacing the symlink with a
        # real file (the same drift ~/.claude/settings.json needs force = true
        # for), so settings.json / CLAUDE.md are relinked unconditionally.
        # skills / commands are only relinked when absent or already a symlink —
        # a real directory there is profile-local data, not drift.
        home.activation.linkClaudeProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          profiles_root="${config.home.homeDirectory}/.config/claude/profiles"
          if [ -d "$profiles_root" ]; then
            for dir in "$profiles_root"/*/; do
              dir="''${dir%/}"
              [ -d "$dir" ] || continue
              ln -sfn "${dotfilesPath}/${cfg.settingsSource}" "$dir/settings.json"
              ln -sfn "${dotfilesPath}/${sharedClaudeMd}" "$dir/CLAUDE.md"
              for shared in skills commands; do
                if [ -L "$dir/$shared" ] || [ ! -e "$dir/$shared" ]; then
                  ln -sfn "${config.home.homeDirectory}/.claude/$shared" "$dir/$shared"
                fi
              done
            done
          fi
        '';

        # `cc-<name>` launches Claude Code with that profile's isolated config dir.
        programs.zsh.shellAliases = mapAttrs' (
          _: profile: nameValuePair profile.aliasName "CLAUDE_CONFIG_DIR=${profile.configDir} claude"
        ) cfg.profiles;

        # direnv helper: a repo's `.envrc` with `use claude_profile <name>` isolates
        # Claude Code data (history/projects/auth) under ~/.config/claude/profiles/<name>,
        # while sharing the declarative settings.json / CLAUDE.md from the primary config.
        programs.direnv.stdlib = mkAfter ''
          use_claude_profile() {
            local dir="''${XDG_CONFIG_HOME:-$HOME/.config}/claude/profiles/$1"
            mkdir -p "$dir"
            ln -sfn "$HOME/.claude/settings.json" "$dir/settings.json"
            ln -sfn "$HOME/.claude/CLAUDE.md" "$dir/CLAUDE.md"
            ln -sfn "$HOME/.claude/skills" "$dir/skills"
            ln -sfn "$HOME/.claude/commands" "$dir/commands"
            export CLAUDE_CONFIG_DIR="$dir"
          }
        '';
      };
  };
}

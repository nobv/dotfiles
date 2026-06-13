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
    ];

    home-manager.users.${username} =
      { config, ... }:
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
              ".claude/settings.json".source = mkSymlink cfg.settingsSource;
              ".claude/CLAUDE.md".source = mkSymlink sharedClaudeMd;
              ".config/ccstatusline/settings.json".source =
                mkSymlink "modules/ai/claude-code/ccstatusline-settings.json";
            }
          ]
          ++ (mapAttrsToList (_: profile: {
            "${homeRel profile}/settings.json".source = mkSymlink profile.settingsSource;
            "${homeRel profile}/CLAUDE.md".source = mkSymlink sharedClaudeMd;
          }) cfg.profiles)
        );

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
            export CLAUDE_CONFIG_DIR="$dir"
          }
        '';
      };
  };
}

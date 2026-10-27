# Claude Code recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

MACHINE := env("DOTFILES_MACHINE", "macbook")

# The repo settings.json this machine links ~/.claude/settings.json to (work uses a git-ignored one)
SETTINGS := "nix eval --raw .#darwinConfigurations." + MACHINE + ".config.modules.ai.claude-code.settingsSource 2>/dev/null"

# Sync Claude Code native plugins from settings.json (marketplace add + install; idempotent)
plugins:
    ./scripts/claude-plugin-sync.sh

# Fail if live settings.json has drifted with changes the next switch would discard
drift:
    ./scripts/claude-settings-backport.sh "$({{SETTINGS}})" --check

# Backport live settings.json into the repo, open a PR and merge it (interactive, live->repo)
backport *ARGS:
    ./scripts/claude-settings-backport.sh "$({{SETTINGS}})" {{ARGS}}

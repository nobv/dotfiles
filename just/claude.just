# Claude Code recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

# Sync Claude Code native plugins from settings.json (marketplace add + install; idempotent)
plugins:
    ./scripts/claude-plugin-sync.sh

# Fail if live settings.json has drifted with changes the next switch would discard
drift:
    ./scripts/claude-settings-backport.sh --check

# Backport live settings.json into the repo, open a PR and merge it (interactive, live->repo)
backport *ARGS:
    ./scripts/claude-settings-backport.sh {{ARGS}}

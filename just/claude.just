# Claude Code recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

# Sync Claude Code native plugins from settings.json (marketplace add + install; idempotent)
plugins:
    ./scripts/claude-plugin-sync.sh

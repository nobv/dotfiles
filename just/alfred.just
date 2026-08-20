# Alfred recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

# Install the workflows listed in modules/productivity/alfred/workflows.txt (idempotent; no-op runs make no network requests)
sync:
    ./scripts/alfred-workflow-sync.sh

# Alfred recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

# Install the workflows listed in modules/productivity/alfred/workflows.txt (idempotent; no-op runs make no network requests)
sync:
    ./scripts/alfred-workflows.sh sync

# Record workflows installed here but missing from the manifest (commit the diff afterwards)
add:
    ./scripts/alfred-workflows.sh add

# Git recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

# Fast-forward the local main branch to origin/main. Safe to run from any worktree.
sync:
    #!/usr/bin/env bash
    set -euo pipefail
    root="$(git worktree list --porcelain | sed -n 's/^worktree //p' | head -1)"
    git -C "$root" fetch origin
    git -C "$root" merge --ff-only origin/main
    echo "main -> $(git -C "$root" rev-parse --short main)"

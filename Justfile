MACHINE := env("DOTFILES_MACHINE", "macbook")

default:
    @just --list

dry-run:
    darwin-rebuild switch --flake .#{{MACHINE}} --dry-run

switch:
    sudo darwin-rebuild switch --flake .#{{MACHINE}}
    # just apm-sync
    just gc

# Collect Nix garbage, keeping generations from the last 3 days (rollback stays available)
gc:
    sudo nix-collect-garbage --delete-older-than 3d

# Fast-forward the local main branch to origin/main. Safe to run from any worktree.
sync-main:
    #!/usr/bin/env bash
    set -euo pipefail
    root="$(git worktree list --porcelain | sed -n 's/^worktree //p' | head -1)"
    git -C "$root" fetch origin
    git -C "$root" merge --ff-only origin/main
    echo "main -> $(git -C "$root" rev-parse --short main)"

check:
    nix flake check

fmt:
    nix fmt

update:
    nix flake update

update-input INPUT:
    nix flake lock --update-input {{INPUT}}

dev:
    nix develop

show:
    nix flake show

modules:
    ./scripts/enable-module.sh {{MACHINE}}

# Sync apm packages (read-only; fails on lockfile drift)
apm-sync:
    apm install --frozen -g

# Sync Claude Code native plugins from settings.json (marketplace add + install; idempotent)
plugin-sync:
    ./scripts/claude-plugin-sync.sh

# Refresh apm dependencies and regenerate lockfile (commit the diff)
apm-update:
    apm update

# Show outdated apm dependencies
apm-outdated:
    apm outdated -g

# Audit apm installation integrity and drift
apm-audit:
    apm audit

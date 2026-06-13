MACHINE := env("DOTFILES_MACHINE", "macbook")

default:
    @just --list

dry-run:
    darwin-rebuild switch --flake .#{{MACHINE}} --dry-run

switch:
    sudo darwin-rebuild switch --flake .#{{MACHINE}}
    # just apm-sync

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

# Refresh apm dependencies and regenerate lockfile (commit the diff)
apm-update:
    apm update

# Show outdated apm dependencies
apm-outdated:
    apm outdated -g

# Audit apm installation integrity and drift
apm-audit:
    apm audit

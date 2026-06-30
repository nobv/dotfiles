# Nix / nix-darwin recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

MACHINE := env("DOTFILES_MACHINE", "macbook")

# Apply the configuration (needs root), then collect garbage
switch:
    sudo darwin-rebuild switch --flake .#{{MACHINE}}
    just nix gc

# Build the system config without root (worktree-safe validation)
build:
    nix build .#darwinConfigurations.{{MACHINE}}.system

# Dry-run activation (needs root; pre-switch check on main)
dry-run:
    sudo darwin-rebuild switch --flake .#{{MACHINE}} --dry-run

# Collect Nix garbage, keeping generations from the last 3 days (rollback stays available)
gc:
    sudo nix-collect-garbage --delete-older-than 3d

# Check the flake (syntax/eval + pre-commit hooks)
check:
    nix flake check

# Format Nix files
fmt:
    nix fmt

# Update all flake inputs
update:
    nix flake update

# Update a single flake input
update-input INPUT:
    nix flake lock --update-input {{INPUT}}

# Show flake outputs
show:
    nix flake show

# Enter the development shell
dev:
    nix develop

# Interactive module enable/disable
modules:
    ./scripts/enable-module.sh {{MACHINE}}

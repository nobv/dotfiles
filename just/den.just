# Den flake-input maintenance. den lives outside dotfiles; flake.lock pins a
# pushed rev, so local den changes need `update` (push + re-pin) to land.
# The *-local recipes build against the working tree instead (lock untouched).
set working-directory := '..'

MACHINE := env("DOTFILES_MACHINE", "macbook")
DEN_PATH := env("DEN_PATH", env("HOME") + "/src/github.com/nobv/den")

# Push den main, re-pin the den input to the pushed rev, and build to validate
update:
    @if [ -n "$(git -C "{{ DEN_PATH }}" status --porcelain)" ]; then echo "note: den working tree is dirty — uncommitted changes won't be in the pinned rev"; fi
    git -C "{{ DEN_PATH }}" push origin main
    nix flake lock --update-input den
    nix build .#darwinConfigurations.{{ MACHINE }}.system

# Update the den input, then apply the configuration
apply: update
    just nix switch

# Build against the local den working tree (no push; flake.lock untouched)
build-local:
    nix build .#darwinConfigurations.{{ MACHINE }}.system --override-input den "path:{{ DEN_PATH }}" --no-write-lock-file

# Switch against the local den working tree (temporary testing; next `just nix switch` reverts to the pinned rev)
switch-local:
    sudo darwin-rebuild switch --flake .#{{ MACHINE }} --override-input den "path:{{ DEN_PATH }}" --no-write-lock-file

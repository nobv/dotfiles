# Den flake-input maintenance. den lives outside dotfiles; flake.lock pins a
# rev, so local den changes need `update` (push + re-pin) to land.
#
# den's CI builds .#desk on every `v*` tag and publishes the Nix closure as a
# release asset; `pull` imports it so darwin-rebuild substitutes desk instead
# of compiling it. That is why `update` pins a *tag's* rev rather than main
# HEAD — an untagged rev has no closure to pull. The cache is a speedup, not a
# correctness condition: every step below falls back to a local build.
#
# The *-local recipes build against the working tree (lock untouched) and
# always compile — they are for iterating on den before cutting a release.
set working-directory := '..'

MACHINE := env("DOTFILES_MACHINE", "macbook")

# Local den checkout: DEN_PATH env wins; default asks ghq for the repo by
# name, so host/owner moves and GHQ_ROOT changes need no edit here
DEN_PATH := env("DEN_PATH", `ghq list --full-path --exact den | head -n1`)

DEN_REPO := 'nobv/den'
DEN_GIT_URL := 'ssh://git@github.com/nobv/den'

# Push den main, pin the den input to a release tag's rev, import that tag's
# CI-built closure, and build to validate. Defaults to the latest release;
# pass a tag to pin an older one (`just den update v0.2.0`).
update tag="":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -n "$(git -C "{{ DEN_PATH }}" status --porcelain)" ]; then
        echo "note: den working tree is dirty — uncommitted changes won't be in the pinned rev"
    fi
    git -C "{{ DEN_PATH }}" push origin main
    tag="{{ tag }}"
    if [ -z "$tag" ]; then
        tag=$(gh release list -R "{{ DEN_REPO }}" --limit 1 --json tagName --jq '.[0].tagName')
        if [ -z "$tag" ]; then
            echo "den has no releases — cut one first: git tag vX.Y.Z && git push origin vX.Y.Z" >&2
            exit 1
        fi
    fi
    # ^{} dereferences an annotated tag to its commit; lightweight tags have
    # no ^{} line, so fall back to the ref itself
    rev=$(git ls-remote "{{ DEN_GIT_URL }}" "refs/tags/${tag}^{}" | cut -f1)
    if [ -z "$rev" ]; then
        rev=$(git ls-remote "{{ DEN_GIT_URL }}" "refs/tags/${tag}" | cut -f1)
    fi
    if [ -z "$rev" ]; then
        echo "no such tag in {{ DEN_REPO }}: $tag" >&2
        exit 1
    fi
    echo "pinning den to $tag ($rev)"
    # Overriding on `nix flake lock` writes the rev into `locked` while leaving
    # `original` matching flake.nix — a later plain `nix build` keeps this pin
    # instead of drifting back to main HEAD.
    nix flake lock --override-input den "git+{{ DEN_GIT_URL }}?ref=refs/heads/main&rev=${rev}"
    just den pull
    nix build .#darwinConfigurations.{{ MACHINE }}.system

# Update the den input, then apply the configuration
apply tag="": (update tag)
    just nix switch

# Import the release closure for the pinned den rev into the local store. The
# release is created by the build job with the asset attached, so a missing
# release means CI is still running (or failed) — wait for the tag's run when
# there is one. Anything unresolvable exits 0 and lets darwin-rebuild compile.
pull:
    #!/usr/bin/env bash
    set -euo pipefail
    rev=$(jq -r '.nodes.den.locked.rev' flake.lock)
    tag=$(git ls-remote --tags "{{ DEN_GIT_URL }}" \
        | awk -v rev="$rev" '$1 == rev { ref = $2; sub(/\^\{\}$/, "", ref); sub(/^refs\/tags\//, "", ref); print ref }' \
        | head -n1)
    if [ -z "$tag" ]; then
        echo "den rev ${rev:0:12} has no release tag — desk will build locally" >&2
        exit 0
    fi
    echo "den rev ${rev:0:12} → tag $tag"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    if ! gh release download "$tag" -R "{{ DEN_REPO }}" -p desk-nix-cache.tgz -D "$tmp" 2>/dev/null; then
        run_id=$(gh run list -R "{{ DEN_REPO }}" --workflow build-desk.yml --branch "$tag" --limit 1 --json databaseId --jq '.[0].databaseId')
        if [ -z "$run_id" ]; then
            echo "no release and no CI run for $tag — desk will build locally" >&2
            exit 0
        fi
        echo "release not up yet; waiting for CI run $run_id..."
        if ! gh run watch -R "{{ DEN_REPO }}" "$run_id" --exit-status; then
            echo "CI run $run_id did not succeed — desk will build locally" >&2
            exit 0
        fi
        if ! gh release download "$tag" -R "{{ DEN_REPO }}" -p desk-nix-cache.tgz -D "$tmp" 2>/dev/null; then
            echo "CI succeeded but $tag has no closure asset — desk will build locally" >&2
            exit 0
        fi
    fi
    tar -xzf "$tmp/desk-nix-cache.tgz" -C "$tmp"
    out=$(cat "$tmp/nix-cache/out-path.txt")
    if [ -e "$out" ]; then
        echo "already in store: $out"
        exit 0
    fi
    # root imports the unsigned closure (trusted-users = root); provenance is
    # this repo's own CI release, fetched over authenticated gh
    sudo nix copy --from "file://$tmp/nix-cache" --no-check-sigs "$out"
    echo "imported: $out"

# Build against the local den working tree (no push; flake.lock untouched)
build-local:
    nix build .#darwinConfigurations.{{ MACHINE }}.system --override-input den "path:{{ DEN_PATH }}" --no-write-lock-file

# Switch against the local den working tree (temporary testing; next `just nix switch` reverts to the pinned rev)
switch-local:
    sudo darwin-rebuild switch --flake .#{{ MACHINE }} --override-input den "path:{{ DEN_PATH }}" --no-write-lock-file

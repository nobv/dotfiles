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

# Local den checkout: DEN_PATH env wins; otherwise locate it so no path is
# baked in — den's home changes (the repo migration moves it from ~/src into a
# desk, and host/owner could move again). Let ghq resolve the layout: it knows
# where repos live under each root, so nothing here assumes a host/owner
# subpath. The active GHQ_ROOT hides the other roots, so gather every root ghq
# knows about — GHQ_ROOT, the configured ghq.root(s), and `ghq root --all` —
# feed their union back to ghq, and match `den` by name; the origin remote then
# confirms it is *this* den (not some other repo also named den). An empty
# result is left empty on purpose: `git -C ""` is a silent no-op that would
# push *dotfiles* believing it is den, so `check-path` turns "not found" into a
# hard error instead of a wrong push.
DEN_PATH := env("DEN_PATH", `
    roots=$(
        { printf '%s\n' "${GHQ_ROOT:-}" | tr ':' '\n'
          git config --get-all ghq.root 2>/dev/null
          ghq root --all 2>/dev/null
        } | while read -r r; do
            [ -n "$r" ] || continue
            case "$r" in "~"|"~/"*) r="$HOME${r#\~}";; esac
            printf '%s\n' "$r"
        done | awk '!seen[$0]++' | paste -sd: -
    )
    GHQ_ROOT="$roots" ghq list --full-path --exact den 2>/dev/null | while read -r d; do
        case "$(git -C "$d" remote get-url origin 2>/dev/null)" in
            *nobv/den*) printf '%s' "$d"; break;;
        esac
    done
`)

# Refuse to act on anything that is not a den checkout (see DEN_PATH above)
[private]
check-path:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{ DEN_PATH }}" ] || [ ! -d "{{ DEN_PATH }}/.git" ]; then
        echo "no den checkout at '{{ DEN_PATH }}' (GHQ_ROOT=${GHQ_ROOT:-unset}) — pass DEN_PATH=/path/to/den" >&2
        exit 1
    fi
    origin=$(git -C "{{ DEN_PATH }}" remote get-url origin 2>/dev/null || true)
    case "$origin" in
        *nobv/den*) ;;
        *)
            echo "'{{ DEN_PATH }}' is not den (origin: ${origin:-none}) — refusing to push or build it as den" >&2
            exit 1
            ;;
    esac

DEN_REPO := 'nobv/den'
DEN_GIT_URL := 'ssh://git@github.com/nobv/den'

# Push den main, pin the den input to a release tag's rev, import that tag's
# CI-built closure, and build to validate. Defaults to the latest release;
# pass a tag to pin an older one (`just den update v0.2.0`).
update tag="": check-path
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
build-local: check-path
    nix build .#darwinConfigurations.{{ MACHINE }}.system --override-input den "path:{{ DEN_PATH }}" --no-write-lock-file

# Switch against the local den working tree (temporary testing; next `just nix switch` reverts to the pinned rev)
switch-local: check-path
    sudo darwin-rebuild switch --flake .#{{ MACHINE }} --override-input den "path:{{ DEN_PATH }}" --no-write-lock-file

# Print the resolved den checkout path, empty if there is none. Exists so
# scripts/alfred-workflows.sh can install den's Alfred workflow without
# duplicating the lookup above.
[private]
path:
    @printf '%s' "{{ DEN_PATH }}"

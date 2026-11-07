#!/bin/bash
# Install or refresh crit's Codex plugin. crit merges it into ~/.codex/config.toml.
# On first install, trust the plugin's hooks in Codex's hooks UI.
set -euo pipefail

for cmd in crit codex; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd is not installed; skipping crit Codex sync."
        exit 0
    fi
done

# Running from $HOME selects the global install; CODEX_HOME would redirect it to a profile.
unset CODEX_HOME
cd "$HOME"
crit install codex-plugin --force

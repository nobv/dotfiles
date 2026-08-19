#!/usr/bin/env bash

# active + wired + compressed, the same definition Activity Monitor uses.
# Inactive pages are excluded on purpose: macOS keeps them as reclaimable cache,
# so counting them pins the number near 100% and it stops saying anything.
#
# Page size comes from vm_stat's header rather than being assumed — Apple Silicon
# uses 16384, not 4096.

source "$(dirname "$0")/../colors.sh"

used_pct="$(
  vm_stat | awk -v total="$(sysctl -n hw.memsize)" '
    /page size of/                  { for (i = 1; i <= NF; i++) if ($i == "of") page = $(i + 1) }
    /^Pages active/                 { active = $3 }
    /^Pages wired down/             { wired = $4 }
    /^Pages occupied by compressor/ { compressed = $5 }
    END { printf "%.0f", (active + wired + compressed) * page * 100 / total }
  '
)"

sketchybar --set "$NAME" label="${used_pct}%"

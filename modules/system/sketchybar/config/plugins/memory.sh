#!/usr/bin/env bash

# "Used" here means active + wired + compressed, against total RAM — the same
# definition Activity Monitor's memory-used figure follows. Inactive pages are
# deliberately excluded: macOS keeps them populated as cache and reclaims them on
# demand, so counting them would pin the number near 100% permanently and make it
# say nothing.
#
# vm_stat costs 18ms. The page size is read from vm_stat's own header rather than
# assumed to be 4096 — Apple Silicon uses 16384.

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

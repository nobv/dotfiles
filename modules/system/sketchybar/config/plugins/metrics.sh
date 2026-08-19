#!/usr/bin/env bash

# CPU, memory, swap and temperature from a single macmon sample — cheaper than
# polling `ps` and `vm_stat` separately (11ms/s vs 30ms/s) and consistent, since
# every number comes from one definition.
#
# macmon's ram_usage matches Activity Monitor. Two obvious alternatives do not:
# `top` counts inactive pages and never drops below ~95%, and
# active+wired+compressed from vm_stat undercounts by ~8 points because inactive
# *anonymous* pages are app memory too.
#
# Temperature has no unprivileged alternative — the SMC needs root (which is why
# iStat Menus installs a daemon) and ioreg lists the sensor nodes without values.

source "$(dirname "$0")/../colors.sh"
source "$(dirname "$0")/../stacked.sh"

# 300ms, not the shortest possible: CPU usage over 50ms swings by tens of points
# between ticks, and the extra time is spent waiting, not computing.
sample="$(macmon pipe -s 1 -i 300 2>/dev/null)"

if [ -z "$sample" ]; then
  sketchybar --set cpu label="--"
  sketchybar --set memory label="--"
  sketchybar --set temp label="--"
  exit 0
fi

read -r cpu_pct ram_pct swap_bytes celsius <<EOF
$(
  printf '%s' "$sample" | jq -r '
    # E and P clusters report separately; 4 of each here, so a plain mean works.
    ((.ecpu_usage[1] + .pcpu_usage[1]) / 2 * 100 | round),
    (.memory.ram_usage / .memory.ram_total * 100 | round),
    .memory.swap_usage,
    (.temp.cpu_temp_avg | round)
  ' | paste -sd' ' -
)
EOF

sketchybar --set cpu label="${cpu_pct}%"
sketchybar --set memory label="${ram_pct}%"

if [ "$ram_pct" -ge 90 ]; then
  mem_cap="$RED"
elif [ "$ram_pct" -ge 80 ]; then
  mem_cap="$ORANGE"
else
  mem_cap="$CYAN"
fi

# Swap in use means the machine is already paying for the pressure, so it gets a
# line of its own instead of being folded into the percentage.
if [ "${swap_bytes:-0}" -lt 1048576 ]; then
  swap_label="—"
  swap_color="$COMMENT"
else
  swap_label="$(
    awk -v b="$swap_bytes" 'BEGIN {
      if (b >= 1073741824) printf "%.1fG", b / 1073741824
      else                 printf "%dM", b / 1048576
    }'
  )"
  if [ "$swap_bytes" -ge 4294967296 ]; then
    swap_color="$RED"
    mem_cap="$RED"
  else
    swap_color="$ORANGE"
  fi
fi

sketchybar --set memory.top label="$swap_label" label.color="$swap_color"
sketchybar --set memory.cap background.color="$mem_cap"

align_stacked memory

sketchybar --set temp label="${celsius}°"
if [ "$celsius" -ge 80 ]; then
  sketchybar --set temp.cap background.color="$RED"
else
  sketchybar --set temp.cap background.color="$ORANGE"
fi

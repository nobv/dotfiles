#!/usr/bin/env bash

# Not `top`: `top -l 1` costs 763ms, this costs 34ms, and the values agree
# (9% vs 8.50% when measured side by side). The %cpu column is a per-process
# lifetime average rather than an instant sample, so it lags a sudden spike
# slightly — worth 20x the speed for a number read at a glance.

source "$(dirname "$0")/../colors.sh"

ncpu="$(sysctl -n hw.ncpu)"
usage="$(/bin/ps -A -o %cpu | awk -v n="$ncpu" 'NR > 1 { s += $1 } END { printf "%.0f", s / n }')"

sketchybar --set "$NAME" label="${usage}%"

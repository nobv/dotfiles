#!/usr/bin/env bash

# Summing every process's %CPU and dividing by core count costs 34ms and lands
# within half a point of `top` (measured: 9% vs 8.50%). `top -l 1` is the usual
# recipe for this and takes 763ms — a fifth of a second of real work on every
# tick, which is not something to spend on a number in the corner.
#
# The value is each process's average over its lifetime rather than a true
# instantaneous sample, so it lags a sudden spike slightly. For a bar read at a
# glance that trade is worth 20x the speed.

source "$(dirname "$0")/../colors.sh"

ncpu="$(sysctl -n hw.ncpu)"
usage="$(/bin/ps -A -o %cpu | awk -v n="$ncpu" 'NR > 1 { s += $1 } END { printf "%.0f", s / n }')"

sketchybar --set "$NAME" label="${usage}%"

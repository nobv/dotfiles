#!/usr/bin/env bash

# CPU temperature, read without root.
#
# The obvious routes both need privileges: the SMC (IOKit AppleSMC) is what iStat
# Menus reads through the root daemon it installs, and `powermetrics` refuses to
# run unprivileged. `ioreg` is not an escape hatch either — the sensor nodes are
# listed (`smctempsensor0`, `sensor = "mTPL"`) but carry no values.
#
# macmon reaches the same counters through IOReport, which needs no privileges at
# all, so this stays a plain user-level poll and the number can be drawn in our
# own colours rather than mirrored from another app's menu-bar rendering.
#
# Cost: ~1.2s per sample, essentially all of it macmon's IOReport setup —
# shortening `-i` does not help. Hence the slow tick in sketchybarrc; temperature
# does not move fast enough for that to matter.

source "$(dirname "$0")/../colors.sh"

celsius="$(macmon pipe -s 1 -i 50 2>/dev/null | jq -r '.temp.cpu_temp_avg // empty' 2>/dev/null)"

if [ -z "$celsius" ]; then
  sketchybar --set "$NAME" label="--"
  sketchybar --set "$NAME.cap" background.color="$COMMENT"
  exit 0
fi

rounded="$(printf '%.0f' "$celsius")"

# Sustained load on this machine sits in the 60s; 80 is where the fans commit.
if [ "$rounded" -ge 80 ]; then
  cap="$RED"
else
  cap="$ORANGE"
fi

sketchybar --set "$NAME" label="${rounded}°"
sketchybar --set "$NAME.cap" background.color="$cap"

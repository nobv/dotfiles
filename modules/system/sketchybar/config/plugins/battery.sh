#!/usr/bin/env bash

# Charge level, how long it lasts, and — the part pmset alone cannot tell you —
# whether charging is actually happening.
#
# The `battery` CLI holds this machine at 80% by flipping an SMC charging bit, so
# "plugged in" and "charging" are different states here. pmset reports the wall
# power; `battery status` reports the SMC bit and the ceiling. Three states come
# out of the pair:
#
#   discharging  on battery          → time remaining
#   charging     AC, SMC allows      → climbing toward the ceiling
#   held         AC, SMC blocks      → parked at the ceiling, deliberately
#
# Without the third state the item would read "plugged in but not charging" as a
# fault, when it is the whole point of running that tool.
#
# Two lines, stacked: the estimate above the percentage, the way iStat shows it.
# Cost is ~107ms for both probes (pmset 22ms + battery status 85ms).

source "$(dirname "$0")/../colors.sh"

power="$(pmset -g batt)"
smc="$(battery status 2>/dev/null)"

pct="$(printf '%s' "$power" | grep -o '[0-9]\{1,3\}%' | head -1 | tr -d '%')"

if [ -z "$pct" ]; then
  # Desktop, or pmset had nothing to say. Drawing 0% would be a lie.
  sketchybar --set "$NAME.pill" drawing=off
  exit 0
fi
sketchybar --set "$NAME.pill" drawing=on

# "6:44 remaining" while discharging, "1:12 until full" while charging, and
# absent for a few minutes after waking or plugging in.
estimate="$(printf '%s' "$power" | grep -o '[0-9]\{1,2\}:[0-9]\{2\}' | head -1)"
ceiling="$(printf '%s' "$smc" | sed -n 's/.*maintained at \([0-9]*\)%.*/\1/p' | head -1)"

case "$power" in
  *"AC Power"*) on_ac=1 ;;
  *) on_ac=0 ;;
esac
case "$smc" in
  *"smc charging enabled"*) smc_allows=1 ;;
  *) smc_allows=0 ;;
esac

if [ "$on_ac" = 0 ]; then
  icon="$ICON_BATT"
  top="${estimate:-—}"
  if [ "$pct" -le 20 ]; then cap="$RED"; else cap="$YELLOW"; fi
elif [ "$smc_allows" = 1 ]; then
  icon="$ICON_BATT_CHARGE"
  cap="$GREEN"
  top="${estimate:-charging}"
else
  # Plugged in, charging deliberately blocked: parked at the ceiling.
  icon="$ICON_BATT_HOLD"
  cap="$CYAN"
  top="hold ${ceiling:-?}%"
fi

sketchybar --set "$NAME" label="${pct}%"
# The upper line takes the cap's colour rather than a muted grey: at 9pt on a
# translucent bar, Dracula's comment blue is too close to the background to read,
# and tinting it says the same thing the cap already says.
sketchybar --set "$NAME.top" label="$top" label.color="$cap"
sketchybar --set "$NAME.cap" icon="$icon" background.color="$cap"

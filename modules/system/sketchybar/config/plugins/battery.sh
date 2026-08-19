#!/usr/bin/env bash

# The `battery` CLI holds this machine at 80% by flipping an SMC charging bit, so
# "plugged in" and "charging" are different states. pmset only knows the former —
# without `battery status`, a deliberate hold reads as a fault.

source "$(dirname "$0")/../colors.sh"
source "$(dirname "$0")/../stacked.sh"

power="$(pmset -g batt)"
smc="$(battery status 2>/dev/null)"

pct="$(printf '%s' "$power" | grep -o '[0-9]\{1,3\}%' | head -1 | tr -d '%')"

if [ -z "$pct" ]; then
  sketchybar --set "$NAME.pill" drawing=off
  exit 0
fi
sketchybar --set "$NAME.pill" drawing=on

# Absent for a few minutes after waking or plugging in.
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

# pmset reports the same "H:MM" shape for both directions, so the word matters:
# on battery it is time left, while charging it is time until full.
if [ "$on_ac" = 0 ]; then
  icon="$ICON_BATT"
  top="${estimate:+$estimate left}"
  top="${top:-—}"
  if [ "$pct" -le 20 ]; then cap="$RED"; else cap="$YELLOW"; fi
elif [ "$smc_allows" = 1 ]; then
  icon="$ICON_BATT_CHARGE"
  cap="$GREEN"
  top="${estimate:+$estimate to full}"
  top="${top:-charging}"
else
  icon="$ICON_BATT_HOLD"
  cap="$CYAN"
  top="hold ${ceiling:-?}%"
fi

sketchybar --set "$NAME" label="${pct}%"
# Tinted to match the cap: a muted grey at 9pt disappears into the bar.
sketchybar --set "$NAME.top" label="$top" label.color="$cap"
sketchybar --set "$NAME.cap" icon="$icon" background.color="$cap"

align_stacked "$NAME"

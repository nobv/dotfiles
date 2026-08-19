#!/usr/bin/env bash

# macmon reads the sensors through IOReport, which needs no privileges. The
# alternatives all do: the SMC (what iStat Menus runs a root daemon for) and
# powermetrics. `ioreg` lists the sensor nodes but carries no values.
#
# ~1.2s per sample, essentially all of it macmon's setup — shortening `-i` does
# not help, hence the slow tick in sketchybarrc.

source "$(dirname "$0")/../colors.sh"

celsius="$(macmon pipe -s 1 -i 50 2>/dev/null | jq -r '.temp.cpu_temp_avg // empty' 2>/dev/null)"

if [ -z "$celsius" ]; then
  sketchybar --set "$NAME" label="--"
  sketchybar --set "$NAME.cap" background.color="$COMMENT"
  exit 0
fi

rounded="$(printf '%.0f' "$celsius")"

if [ "$rounded" -ge 80 ]; then
  cap="$RED"
else
  cap="$ORANGE"
fi

sketchybar --set "$NAME" label="${rounded}°"
sketchybar --set "$NAME.cap" background.color="$cap"

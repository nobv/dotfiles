#!/usr/bin/env bash

# Identify a menu-bar item so it can be aliased into the bar.
#
#   ./find-menu-item.sh          lay every unidentified item on the bar, labelled
#                                with its index, and print the mapping
#   ./find-menu-item.sh --sizes  measure what each alias actually captures
#   sketchybar --reload          undo
#
# Most items are named `Control Center,Item-0(N)`, where N is a position index
# that moves with menu-bar order — FineTune went 13 -> 17 -> 18 -> 20 in one
# session here. Items with a real name are stable and need no help.
#
# Two traps: menu-bar managers that reposition items (Bartender) make aliases
# capture the wrong rect, so quit them before probing; and a name like
# `FineTune,FineTune` can refer to the app's window rather than its icon, showing
# up as a ~528px slab. A real icon is roughly 25-80px wide.

set -u

sketchybar --bar topmost=on >/dev/null

if [ "${1:-}" = "--sizes" ]; then
  sketchybar --query bar | jq -r '.items[]' | while IFS= read -r name; do
    case "$name" in
      probe* | desk | clock) continue ;;
    esac
    w=$(sketchybar --query "$name" 2>/dev/null | jq -r '.bounding_rects["display-1"].size[0] // "n/a"')
    printf '%-72s width=%s\n' "$name" "${w%.*}"
  done
  exit 0
fi

idx=0
while IFS= read -r item; do
  case "$item" in
    *istatmenus* | *",Clock("* | *BentoBox* | *FocusModes* | *NowPlaying* | \
      *",WiFi("* | *Bluetooth* | *Siri* | *",Battery("* | *raycastIcon* | \
      Karabiner* | Bartender*)
      continue
      ;;
  esac

  n="${item##*\(}"
  n="${n%\)}"
  idx=$((idx + 1))

  sketchybar --add item "probe$idx" left >/dev/null
  sketchybar --set "probe$idx" \
    icon.drawing=off \
    label="$n" \
    label.color=0xffffff00 \
    label.font="UDEV Gothic 35NFLG:Bold:12.0" \
    label.padding_left=10 \
    label.padding_right=1 >/dev/null

  sketchybar --add alias "$item" left >/dev/null
  sketchybar --set "$item" \
    background.drawing=on \
    background.color=0x30ffffff \
    background.height=24 \
    background.corner_radius=4 >/dev/null

  printf '%-4s <- %s\n' "$n" "$item"
done < <(sketchybar --query default_menu_items | jq -r '.[]')

sketchybar --update >/dev/null
echo "--- $idx items on the bar; 'sketchybar --reload' to undo"

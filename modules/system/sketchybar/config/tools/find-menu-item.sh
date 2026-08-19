#!/usr/bin/env bash

# Identify a menu-bar item so it can be aliased into the bar.
#
# Why this exists: `sketchybar --query default_menu_items` names most items
# `Control Center,Item-0(N)`, where N is a position index that changes whenever
# the menu-bar order changes — a measured example: FineTune moved 13 -> 17 -> 20
# across a single session. Items with a real name (`com.bjango.istatmenus.cpu`,
# `FineTune,FineTune`) are stable and need no help; this script is for the rest.
#
# Usage:
#   ./find-menu-item.sh          lay every unidentified item on the bar, each
#                                labelled with its index, and print the mapping
#   ./find-menu-item.sh --sizes  measure what each alias actually captures
#   sketchybar --reload          undo (this script never edits the config)
#
# Read the bar, note which index shows the app you want, then take the full name
# from the printed mapping and add it to sketchybarrc.
#
# Two traps, both hit during the original investigation:
#   - Menu-bar managers that reposition items (Bartender) make aliases capture
#     the WRONG rect — neighbouring items bleed in. Quit them before probing.
#   - A name like `FineTune,FineTune` can refer to the app's window rather than
#     its menu-bar icon; it renders as a ~528px slab. Check --sizes: a real icon
#     is roughly 25-80px wide.

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
  # Skip what is already identified or known not to be an icon.
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
    label.font="Hack Nerd Font:Bold:12.0" \
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

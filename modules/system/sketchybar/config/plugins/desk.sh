#!/usr/bin/env bash

# `~/Desk` decides where files are saved and which identity you act under; the
# focused workspace is only what is on screen. When they disagree you are typing
# into one domain's windows while everything else lands in another — the state
# this item exists to make visible.
#
# break / shelf are not that: they are stepped into on purpose (alt-b / alt-s),
# so they read as neutral instead of a warning.

source "$(dirname "$0")/../colors.sh"

desk="$(desk list --json 2>/dev/null | jq -r '.current // empty' 2>/dev/null)"
workspace="$(aerospace list-workspaces --focused 2>/dev/null)"

icon="$ICON_DESK"
cap="$PURPLE"
body="$PILL"
text="$FG"
label="$desk"

if [ -z "$desk" ]; then
  # An empty item would read as "no problem".
  icon="$ICON_WARN"
  cap="$RED"
  body="$PILL_WARN"
  text="$RED"
  label="desk?"
elif [ -z "$workspace" ]; then
  # AeroSpace is down; the desk is still true but nothing can be compared.
  cap="$COMMENT"
  text="$COMMENT"
elif [ "$desk" = "$workspace" ]; then
  :
elif [ "$workspace" = "break" ] || [ "$workspace" = "shelf" ]; then
  cap="$COMMENT"
  text="$COMMENT"
  label="$desk · $workspace"
else
  icon="$ICON_WARN"
  cap="$RED"
  body="$PILL_WARN"
  text="$RED"
  label="$desk ≠ $workspace"
fi

sketchybar --set "$NAME" label="$label" label.color="$text"
sketchybar --set "$NAME.cap" icon="$icon" background.color="$cap"
sketchybar --set "$NAME.pill" background.color="$body"

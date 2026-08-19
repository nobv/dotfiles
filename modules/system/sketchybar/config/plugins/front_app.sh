#!/usr/bin/env bash

# Which window has focus is hard to read off a tiled layout — AeroSpace draws no
# title bars and every tile looks equally active.
#
# Event-driven: sketchybar fills $INFO with the app name on front_app_switched,
# so there is nothing to sample. $INFO is empty on the startup --update though
# (no switch has happened yet), and an empty pill at launch reads as broken, so
# fall back to asking AeroSpace once. No new dependency — the desk item already
# relies on the same binary.

source "$(dirname "$0")/../colors.sh"

app="$INFO"
[ -z "$app" ] && app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -1)"

sketchybar --set "$NAME" label="$app"

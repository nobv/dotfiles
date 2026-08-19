#!/usr/bin/env bash

# $INFO is filled by front_app_switched, but is empty on the startup --update, so
# fall back to asking AeroSpace once — an empty pill at launch reads as broken.

source "$(dirname "$0")/../colors.sh"

app="$INFO"
[ -z "$app" ] && app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -1)"

sketchybar --set "$NAME" label="$app"

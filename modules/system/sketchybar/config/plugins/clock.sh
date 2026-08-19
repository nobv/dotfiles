#!/usr/bin/env bash

source "$(dirname "$0")/../colors.sh"

sketchybar --set "$NAME" label="$(date '+%-m/%-d (%a) %H:%M')"

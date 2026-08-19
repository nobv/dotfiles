#!/usr/bin/env bash

# Date and time in one item. The weekday comes out in English because the
# launchd agent sets LANG=en_US.UTF-8 (sketchybar's formula requires a UTF-8
# locale, and en_US is what its caveat names).

source "$(dirname "$0")/../colors.sh"

sketchybar --set "$NAME" label="$(date '+%-m/%-d (%a) %H:%M')"

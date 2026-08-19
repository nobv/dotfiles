#!/usr/bin/env bash

# The two lines of a stacked pill are separate items, so nothing makes them share
# a width. Left alone the shorter one sits flush against the pill's right edge,
# and the wider line is what sizes the pill — so it also decides whether the
# other one fits. Measure both at their natural width, then hold both at the
# wider one; label.align=center does the rest.
align_stacked() {
  local name="$1" wide

  sketchybar --set "$name" label.width=dynamic --set "$name.top" label.width=dynamic
  wide="$(sketchybar --query "$name" --query "$name.top" | jq -s 'map(.label.width) | max')"
  sketchybar --set "$name" label.width="$wide" --set "$name.top" label.width="$wide"
}

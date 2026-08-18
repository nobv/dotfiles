#!/usr/bin/env bash

# Show which desk you are actually at versus which AeroSpace workspace has focus.
#
# The two are normally the same name (den creates one workspace per desk), but
# they can drift: `~/Desk` is what decides where files are saved and which
# identity you act under, while the workspace is only what is on screen. When
# they disagree you are typing into one domain's windows while everything else
# lands in another — that is the state this item exists to make visible.
#
# break / shelf are not drift. They are the domain-independent workspaces you
# step into on purpose (alt-b / alt-s), so they render as neutral secondary text
# rather than a warning; warning on them would fire every time the shelf is
# peeked at.
#
# PATH is supplied by the launchd agent (see default.nix) — a login shell's PATH
# is not inherited here, so `desk`, `aerospace` and `jq` would otherwise all be
# missing at runtime while everything still builds fine.

COLOR_OK=0xffffffff
COLOR_NEUTRAL=0xff999999
COLOR_WARN=0xffff5f5f

ICON_DESK=""    # nf-fa-desktop
ICON_WARN=""    # nf-fa-warning

desk="$(desk list --json 2>/dev/null | jq -r '.current // empty' 2>/dev/null)"
workspace="$(aerospace list-workspaces --focused 2>/dev/null)"

if [ -z "$desk" ]; then
  # den is not answering (not deployed, or ~/Desk is broken). Say so rather than
  # rendering an empty item that reads as "no problem".
  icon="$ICON_WARN"
  label="desk?"
  color="$COLOR_WARN"
elif [ -z "$workspace" ]; then
  # AeroSpace is not running, so there is nothing to compare against. The desk is
  # still true, so show it — dimmed, to mark the comparison as unavailable.
  icon="$ICON_DESK"
  label="$desk"
  color="$COLOR_NEUTRAL"
elif [ "$desk" = "$workspace" ]; then
  icon="$ICON_DESK"
  label="$desk"
  color="$COLOR_OK"
elif [ "$workspace" = "break" ] || [ "$workspace" = "shelf" ]; then
  icon="$ICON_DESK"
  label="$desk · $workspace"
  color="$COLOR_NEUTRAL"
else
  icon="$ICON_WARN"
  label="$desk ≠ $workspace"
  color="$COLOR_WARN"
fi

sketchybar --set "$NAME" \
  icon="$icon" \
  label="$label" \
  icon.color="$color" \
  label.color="$color"

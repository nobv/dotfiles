#!/usr/bin/env bash

set -euo pipefail

AEROSPACE_BIN="${AEROSPACE_BIN:-/opt/homebrew/bin/aerospace}"
AQUA_VOICE_BUNDLE_ID="${AQUA_VOICE_BUNDLE_ID:-com.electron.aqua-voice}"

if ! command -v "$AEROSPACE_BIN" >/dev/null 2>&1; then
  exit 0
fi

focused_workspace="$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null | awk 'NR==1 { print $1 }')"

if [ -z "${focused_workspace:-}" ]; then
  exit 0
fi

"$AEROSPACE_BIN" list-windows --monitor all --app-bundle-id "$AQUA_VOICE_BUNDLE_ID" 2>/dev/null \
  | awk '$1 ~ /^[0-9]+$/ { print $1 }' \
  | while read -r window_id; do
    "$AEROSPACE_BIN" move-node-to-workspace --window-id "$window_id" "$focused_workspace" >/dev/null 2>&1 || true
  done

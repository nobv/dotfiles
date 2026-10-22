#!/usr/bin/env bash

set -euo pipefail

# Usage: follow-aqua-voice.sh [--dry-run]
# Focus callbacks can overlap; keep one worker moving AquaVoice at a time.
if [ "${1:-}" != "--locked" ]; then
  exec /usr/bin/lockf -k -t 1 "${TMPDIR:-/tmp}/aerospace-follow-aqua-voice-${UID}.lock" \
    /bin/bash "$0" --locked "$@"
fi
shift

dry_run=false
case "${1:-}" in
  "") ;;
  --dry-run) dry_run=true ;;
  *) exit 2 ;;
esac

AEROSPACE_BIN="${AEROSPACE_BIN:-/opt/homebrew/bin/aerospace}"
AQUA_VOICE_BUNDLE_ID="${AQUA_VOICE_BUNDLE_ID:-com.electron.aqua-voice}"

if ! command -v "$AEROSPACE_BIN" >/dev/null 2>&1; then
  exit 0
fi

if ! windows="$("$AEROSPACE_BIN" list-windows --monitor all --app-bundle-id "$AQUA_VOICE_BUNDLE_ID" \
  --format '%{window-id}|%{workspace}' 2>/dev/null)"; then
  exit 0
fi

while IFS='|' read -r window_id window_workspace; do
  [[ "$window_id" =~ ^[0-9]+$ ]] || continue

  # Query the current focus, since another workspace switch may have overtaken
  # this callback. Avoid re-moving windows already carried by desk switch.
  focused_workspace="$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null)" || exit 0
  if [ -z "$focused_workspace" ] || [ "$window_workspace" = "$focused_workspace" ]; then
    continue
  fi

  if "$dry_run"; then
    printf 'move-node-to-workspace --window-id %s -- %q\n' "$window_id" "$focused_workspace"
  else
    "$AEROSPACE_BIN" move-node-to-workspace --fail-if-noop --window-id "$window_id" \
      -- "$focused_workspace" >/dev/null 2>&1 || true
  fi
done <<< "$windows"

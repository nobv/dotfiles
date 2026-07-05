#!/usr/bin/env bash
# Unit tests for claude-settings-backport.sh (source functions, no main run).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${HERE}/../claude-settings-backport.sh"   # main ガードにより実行はされない

PASS=0 FAIL=0
assert_eq() { # actual expected msg
  if [ "$1" = "$2" ]; then PASS=$((PASS+1));
  else FAIL=$((FAIL+1)); echo "FAIL: $3 (expected '$2' got '$1')"; fi
}
fixture_dir() { mktemp -d; }

# --- is_drifted ---
d="$(fixture_dir)"
: > "$d/real.json"; LIVE="$d/real.json"
if is_drifted; then assert_eq drift drift "is_drifted: real file is drifted"; else assert_eq nodrift drift "is_drifted: real file"; fi
ln -s /nonexistent "$d/link.json"; LIVE="$d/link.json"
if is_drifted; then assert_eq drift nodrift "is_drifted: symlink"; else assert_eq nodrift nodrift "is_drifted: symlink not drifted"; fi

# --- parse_args ---
parse_args --dry-run --all
assert_eq "$DRY_RUN" true  "parse_args: --dry-run sets DRY_RUN"
assert_eq "$ALL"     true  "parse_args: --all sets ALL"
assert_eq "$NO_PR"   false "parse_args: NO_PR default false"
parse_args custom/path.json --no-merge
assert_eq "$REPO_REL"  "custom/path.json" "parse_args: positional repo path"
assert_eq "$NO_MERGE"  true "parse_args: --no-merge"

echo "PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]

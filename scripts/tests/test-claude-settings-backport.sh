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

# --- diff_keys ---
d="$(fixture_dir)"
cat > "$d/live.json" <<'JSON'
{ "model": "x", "enabledPlugins": {"a": true, "b": true}, "same": {"k": 1}, "onlyLive": 1 }
JSON
cat > "$d/repo.json" <<'JSON'
{ "model": "y", "enabledPlugins": {"a": true}, "same": {"k": 1}, "repoOnly": 1 }
JSON
got="$(diff_keys "$d/live.json" "$d/repo.json" | sort | tr '\n' ',')"
# model: 値違い→候補 / enabledPlugins: 内容違い→候補 / same: 一致→除外 / repoOnly: repo固有→除外
assert_eq "$got" "enabledPlugins,model,onlyLive," "diff_keys: added/changed keys only, repo-only excluded"

# --- apply_keys ---
d="$(fixture_dir)"
cat > "$d/live.json" <<'JSON'
{ "enabledPlugins": {"a": true, "b": true}, "hooks": {"h": 1} }
JSON
cat > "$d/repo.json" <<'JSON'
{ "enabledPlugins": {"a": true}, "model": "keep" }
JSON
apply_keys "$d/repo.json" "$d/live.json" enabledPlugins
assert_eq "$(jq -c '.enabledPlugins' "$d/repo.json")" '{"a":true,"b":true}' "apply_keys: key replaced with live value"
assert_eq "$(jq -r '.model' "$d/repo.json")" "keep" "apply_keys: repo-only key preserved"
assert_eq "$(jq 'has("hooks")' "$d/repo.json")" "false" "apply_keys: non-approved key not added"

# --- select_keys (--all) & commit_message ---
d="$(fixture_dir)"
cat > "$d/live.json" <<'JSON'
{ "enabledPlugins": {"a": true}, "hooks": {"h": 1} }
JSON
ALL=true
select_keys "$d/live.json" enabledPlugins hooks
assert_eq "${APPROVED[*]}" "enabledPlugins hooks" "select_keys: --all approves all"
APPROVED=(enabledPlugins hooks)
assert_eq "$(commit_message)" "chore(claude): backport settings.json (enabledPlugins, hooks)" "commit_message: joins keys"

# --- open_pr uses gh pr create when no PR exists (gh stubbed) ---
d="$(fixture_dir)"; stub="$d/bin"; mkdir -p "$stub"
cat > "$stub/gh" <<'SH'
#!/usr/bin/env bash
# stub: `gh pr view` -> fail(=PR なし), `gh pr create` -> ログ記録
if [ "$1" = "pr" ] && [ "$2" = "view" ]; then exit 1; fi
if [ "$1" = "pr" ] && [ "$2" = "create" ]; then echo "create $*" >> "$GH_LOG"; echo "https://x/pr/1"; exit 0; fi
exit 0
SH
chmod +x "$stub/gh"
export GH_LOG="$d/gh.log"; : > "$GH_LOG"
PATH="$stub:$PATH" BRANCH="chore/claude-settings-backport" open_pr
assert_eq "$(grep -c '^create ' "$GH_LOG")" "1" "open_pr: calls gh pr create when no PR"

# --- merge_pr: success path ---
d="$(fixture_dir)"; stub="$d/bin"; mkdir -p "$stub"
cat > "$stub/gh" <<'SH'
#!/usr/bin/env bash
if [ "$1" = "pr" ] && [ "$2" = "merge" ]; then echo "merged" >> "$GH_LOG"; exit 0; fi
exit 0
SH
chmod +x "$stub/gh"; export GH_LOG="$d/gh.log"; : > "$GH_LOG"
PATH="$stub:$PATH" merge_pr && rc=0 || rc=1
assert_eq "$rc" "0" "merge_pr: returns 0 on success"
assert_eq "$(grep -c merged "$GH_LOG")" "1" "merge_pr: calls gh pr merge"

# --- merge_pr: failure falls back to return 0 ---
cat > "$stub/gh" <<'SH'
#!/usr/bin/env bash
if [ "$1" = "pr" ] && [ "$2" = "merge" ]; then exit 1; fi
if [ "$1" = "pr" ] && [ "$2" = "view" ]; then echo "https://x/pr/1"; exit 0; fi
exit 0
SH
chmod +x "$stub/gh"
PATH="$stub:$PATH" merge_pr && rc=0 || rc=1
assert_eq "$rc" "0" "merge_pr: returns 0 (fallback) on merge failure"

echo "PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]

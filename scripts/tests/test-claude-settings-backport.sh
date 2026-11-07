#!/usr/bin/env bash
# Unit tests for claude-settings-backport.sh (source functions, no main run).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${HERE}/../claude-settings-backport.sh"   # main ガードにより実行はされない
# 注意: 上の source で script の `set -euo pipefail` が走り、この harness シェルでも
# `-e` が有効化される(source によるシェルオプション変更はスコープされない)。以降、
# 非ゼロを返し得る関数を呼ぶアサーションは必ず `if` / `$(...)` / `&&`・`||` で包むこと。
# 素の呼び出しが失敗すると PASS=/FAIL= 行も出ずにテスト全体が沈黙終了する。

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
assert_eq "$(grep -c -- '--base main --head chore/claude-settings-backport' "$GH_LOG")" "1" "open_pr: passes --base main --head BRANCH"

# --- merge_pr: success path ---
d="$(fixture_dir)"; stub="$d/bin"; mkdir -p "$stub"
cat > "$stub/gh" <<'SH'
#!/usr/bin/env bash
if [ "$1" = "pr" ] && [ "$2" = "merge" ]; then echo "merge $*" >> "$GH_LOG"; exit 0; fi
exit 0
SH
chmod +x "$stub/gh"; export GH_LOG="$d/gh.log"; : > "$GH_LOG"
PATH="$stub:$PATH" BRANCH="chore/claude-settings-backport" merge_pr && rc=0 || rc=1
assert_eq "$rc" "0" "merge_pr: returns 0 on success"
assert_eq "$(grep -c -- '^merge pr merge chore/claude-settings-backport --merge --delete-branch' "$GH_LOG")" "1" "merge_pr: calls gh pr merge with --merge --delete-branch and BRANCH"

# --- merge_pr: failure falls back to return 0 ---
cat > "$stub/gh" <<'SH'
#!/usr/bin/env bash
if [ "$1" = "pr" ] && [ "$2" = "merge" ]; then exit 1; fi
if [ "$1" = "pr" ] && [ "$2" = "view" ]; then echo "https://x/pr/1"; exit 0; fi
exit 0
SH
chmod +x "$stub/gh"
PATH="$stub:$PATH" BRANCH="chore/claude-settings-backport" merge_pr && rc=0 || rc=1
assert_eq "$rc" "0" "merge_pr: returns 0 (fallback) on merge failure"

# --- select_keys (interactive): last key answered N must not fail ---
d="$(fixture_dir)"
cat > "$d/live.json" <<'JSON'
{ "a": 1, "b": 2 }
JSON
ALL=false
# 通常ファイルだと read のたびに開き直して先頭行を読むため、/dev/tty と同じく
# ストリームとして読めるパイプ(process substitution)で答えを渡す。
if PROMPT_IN=<(printf 'y\nN\n') select_keys "$d/live.json" a b >/dev/null 2>&1; then rc=0; else rc=1; fi
assert_eq "$rc" "0" "select_keys: returns 0 when last key is declined"
assert_eq "${APPROVED[*]}" "a" "select_keys: only y-answered keys approved"

# 一時 git repo(REPO_REL を commit 済み、main ブランチ)を作る。
make_repo() {
  local r; r="$(mktemp -d)"
  git -C "$r" init -q -b main
  git -C "$r" config user.name t; git -C "$r" config user.email t@example.com
  printf '{"k":1}\n' > "$r/s.json"
  git -C "$r" add s.json; git -C "$r" commit -qm init
  printf '%s' "$r"
}

# --- commit_and_push: pre-commit hook without config does not block ---
r="$(make_repo)"
cat > "$r/.git/hooks/pre-commit" <<'SH'
#!/usr/bin/env bash
# pre-commit 本体の挙動を模す: 設定が無く PRE_COMMIT_ALLOW_NO_CONFIG も無ければ失敗
[ -f .pre-commit-config.yaml ] || [ -n "${PRE_COMMIT_ALLOW_NO_CONFIG:-}" ] || exit 1
SH
chmod +x "$r/.git/hooks/pre-commit"
printf '{"k":2}\n' > "$r/s.json"
if (cd "$r" && APPROVED=(k) && REPO_REL=s.json NO_PR=true commit_and_push >/dev/null 2>&1); then rc=0; else rc=1; fi
assert_eq "$rc" "0" "commit_and_push: commits despite missing pre-commit config"
assert_eq "$(git -C "$r" log -1 --format=%s)" "chore(claude): backport settings.json (k)" "commit_and_push: commit created"

# --- restore_on_error: failure returns to ORIG_REF and discards half-applied edit ---
r="$(make_repo)"
git -C "$r" checkout -q -b chore/claude-settings-backport
printf '{"k":3}\n' > "$r/s.json"; git -C "$r" add s.json
(cd "$r" && REPO_REL=s.json ORIG_REF=main TMPDIR="$r" restore_on_error 1 >/dev/null 2>&1) && rc=0 || rc=$?
assert_eq "$rc" "1" "restore_on_error: preserves failing exit code"
assert_eq "$(git -C "$r" branch --show-current)" "main" "restore_on_error: back on ORIG_REF"
assert_eq "$(git -C "$r" status --porcelain -- s.json)" "" "restore_on_error: repo file restored"
backup="$(ls "$r"/claude-settings-backport.* 2>/dev/null | head -1)"
assert_eq "$(cat "$backup" 2>/dev/null)" '{"k":3}' "restore_on_error: half-applied edit backed up"

# --- restore_on_error: success is a no-op ---
r="$(make_repo)"
git -C "$r" checkout -q -b chore/claude-settings-backport
if (cd "$r" && REPO_REL=s.json ORIG_REF=main restore_on_error 0); then rc=0; else rc=1; fi
assert_eq "$rc" "0" "restore_on_error: returns 0 on success"
assert_eq "$(git -C "$r" branch --show-current)" "chore/claude-settings-backport" "restore_on_error: stays on branch on success"

echo "PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]

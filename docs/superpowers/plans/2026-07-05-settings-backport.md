# Claude Code settings.json バックポート機能 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ライブ `~/.claude/settings.json`(drift した実ファイル)の変更を差分承認式で repo に取り込み、既定で PR 作成 → マージまで自動化する `just claude backport` を実装する。

**Architecture:** 単一 bash スクリプト `scripts/claude-settings-backport.sh` を、テスト可能な小さな純粋関数(`is_drifted` / `diff_keys` / `apply_keys` / `commit_message` など)+ オーケストレーションする `main` に分割する。スクリプト末尾の `[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"` ガードにより、テストからは関数だけ source して fixture で検証できる。git を伴う部分はテスト用の一時 git リポジトリで実行し、`gh` は PATH に stub を置いて呼び出しを記録する。

**Tech Stack:** bash, jq, gh, git, just。既存の `scripts/lib.sh`(`log_info`/`log_error`/`log_success`/`log_warning`)と `scripts/claude-plugin-sync.sh` の流儀に合わせる。

## Global Constraints

- ライブ: `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json`
- repo ターゲット既定: `modules/ai/claude-code/settings.json`(第1位置引数で上書き可)
- 比較・マージは **トップレベルキー単位**。`jq -S` で正規化して差分判定。採用キーはライブ値で**丸ごと置換**。
- **repo 固有のトップレベルキー(例 `model`)は削除しない**(取り込みは追加・更新のみ)。
- 固定ブランチ名: `chore/claude-settings-backport`
- 段階抑制フラグ: `--no-merge`(PR まで)/ `--no-pr`(commit まで)/ `--dry-run`(差分表示のみ)。他に `--all` / `--edit`。
- **`switch` は絶対に実行しない**(symlink 復元は PR merge 後に人間が `just apply`)。
- `gh pr merge` 失敗時は `log_warning` + PR URL を出して **exit 0**(PR は残す = `--no-merge` 相当にフォールバック)。
- 既定モードでは `jq`・`gh`、`--no-pr`/`--dry-run` では `jq` のみ必須。
- ログは `scripts/lib.sh` の関数を使う。`set -euo pipefail`。

---

### Task 1: スクリプト骨格・フラグ解析・前提・drift 判定 + テストハーネス

**Files:**
- Create: `scripts/claude-settings-backport.sh`
- Create: `scripts/tests/test-claude-settings-backport.sh`
- Reference: `scripts/lib.sh`(ログ関数)、`scripts/claude-plugin-sync.sh`(流儀)

**Interfaces:**
- Produces:
  - `is_drifted()` — `$LIVE` が「存在し symlink でない」なら exit 0(true)、それ以外 1
  - `parse_args "$@"` — グローバル `DRY_RUN`/`NO_PR`/`NO_MERGE`/`ALL`/`EDIT`(`true`/`false`)、`REPO_REL` を設定
  - グローバル: `CONFIG_DIR`/`LIVE`/`REPO_REL`/`BRANCH`
  - テストヘルパ `assert_eq`/`fixture_dir`

- [ ] **Step 1: 失敗するテストを書く**

Create `scripts/tests/test-claude-settings-backport.sh`:
```bash
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
```

- [ ] **Step 2: 実行して失敗を確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: FAIL — `scripts/claude-settings-backport.sh` が無く source に失敗。

- [ ] **Step 3: スクリプト骨格を実装**

Create `scripts/claude-settings-backport.sh`:
```bash
#!/usr/bin/env bash
# claude-settings-backport.sh — ライブ settings.json の変更を repo に取り込み、
# 既定で PR 作成 → マージまで行う(差分承認式・一方向 live->repo)。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
LIVE="${CONFIG_DIR}/settings.json"
REPO_REL="modules/ai/claude-code/settings.json"
BRANCH="chore/claude-settings-backport"
DRY_RUN=false NO_PR=false NO_MERGE=false ALL=false EDIT=false

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --no-pr)   NO_PR=true ;;
      --no-merge) NO_MERGE=true ;;
      --all)     ALL=true ;;
      --edit)    EDIT=true ;;
      -h|--help) echo "usage: claude-settings-backport.sh [repo-settings-path] [--dry-run|--no-pr|--no-merge|--all|--edit]"; exit 0 ;;
      -*) log_error "unknown flag: $1"; exit 1 ;;
      *) REPO_REL="$1" ;;
    esac
    shift
  done
}

# $LIVE が存在し、かつ symlink でない(=実ファイルに drift)なら true。
is_drifted() { [ -e "$LIVE" ] && [ ! -L "$LIVE" ]; }

main() {
  parse_args "$@"
  : # 後続タスクで肉付け
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

- [ ] **Step 4: テストが通ることを確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: PASS — `PASS=6 FAIL=0`。

- [ ] **Step 5: commit**

```bash
git add scripts/claude-settings-backport.sh scripts/tests/test-claude-settings-backport.sh
git commit -m "feat(claude): scaffold settings backport script with flag parsing"
```

---

### Task 2: 差分検出 `diff_keys`

**Files:**
- Modify: `scripts/claude-settings-backport.sh`(`diff_keys` 追加)
- Modify: `scripts/tests/test-claude-settings-backport.sh`(テスト追加)

**Interfaces:**
- Consumes: `jq`
- Produces: `diff_keys <live-file> <repo-file>` — 「ライブに存在し、repo に無い or `jq -S` 正規化値が異なる」トップレベルキーを 1 行ずつ出力。repo 固有キーは出さない。

- [ ] **Step 1: 失敗するテストを書く**

Append to `scripts/tests/test-claude-settings-backport.sh`(`echo "PASS=..."` 行の前):
```bash
# --- diff_keys ---
d="$(fixture_dir)"
cat > "$d/live.json" <<'JSON'
{ "model": "x", "enabledPlugins": {"a": true, "b": true}, "same": {"k": 1} }
JSON
cat > "$d/repo.json" <<'JSON'
{ "model": "y", "enabledPlugins": {"a": true}, "same": {"k": 1}, "repoOnly": 1 }
JSON
got="$(diff_keys "$d/live.json" "$d/repo.json" | sort | tr '\n' ',')"
# model: 値違い→候補 / enabledPlugins: 内容違い→候補 / same: 一致→除外 / repoOnly: repo固有→除外
assert_eq "$got" "enabledPlugins,model," "diff_keys: added/changed keys only, repo-only excluded"
```

- [ ] **Step 2: 実行して失敗を確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: FAIL — `diff_keys: command not found` 由来で該当 assert が FAIL。

- [ ] **Step 3: `diff_keys` を実装**

`is_drifted()` の下に追加:
```bash
# ライブにあり、repo に無い or 正規化値が異なるトップレベルキーを列挙する。
diff_keys() {
  local live="$1" repo="$2" k
  while IFS= read -r k; do
    if ! jq -e --arg k "$k" 'has($k)' "$repo" >/dev/null 2>&1; then
      printf '%s\n' "$k"
    elif [ "$(jq -S --arg k "$k" '.[$k]' "$live")" != "$(jq -S --arg k "$k" '.[$k]' "$repo")" ]; then
      printf '%s\n' "$k"
    fi
  done < <(jq -r 'keys[]' "$live")
}
```

- [ ] **Step 4: テストが通ることを確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: PASS — `FAIL=0`。

- [ ] **Step 5: commit**

```bash
git add scripts/claude-settings-backport.sh scripts/tests/test-claude-settings-backport.sh
git commit -m "feat(claude): detect top-level key diffs for backport"
```

---

### Task 3: マージ `apply_keys`

**Files:**
- Modify: `scripts/claude-settings-backport.sh`(`apply_keys` 追加)
- Modify: `scripts/tests/test-claude-settings-backport.sh`(テスト追加)

**Interfaces:**
- Consumes: `jq`, `diff_keys`(Task 2)
- Produces: `apply_keys <repo-file> <live-file> <key>...` — 指定キーを live 値で repo に丸ごと反映(atomic write)。他キーは不変。

- [ ] **Step 1: 失敗するテストを書く**

Append(`echo "PASS=..."` の前):
```bash
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
```

- [ ] **Step 2: 実行して失敗を確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: FAIL — `apply_keys: command not found`。

- [ ] **Step 3: `apply_keys` を実装**

`diff_keys()` の下に追加:
```bash
# 指定トップレベルキーを live 値で repo に丸ごと反映する(atomic)。
apply_keys() {
  local repo="$1" live="$2"; shift 2
  local tmp v k
  tmp="$(mktemp)"
  cp "$repo" "$tmp"
  for k in "$@"; do
    v="$(jq -c --arg k "$k" '.[$k]' "$live")"
    jq --arg k "$k" --argjson v "$v" '.[$k] = $v' "$tmp" > "$tmp.next"
    mv "$tmp.next" "$tmp"
  done
  mv "$tmp" "$repo"
}
```

- [ ] **Step 4: テストが通ることを確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: PASS — `FAIL=0`。

- [ ] **Step 5: commit**

```bash
git add scripts/claude-settings-backport.sh scripts/tests/test-claude-settings-backport.sh
git commit -m "feat(claude): merge approved keys into repo settings atomically"
```

---

### Task 4: 承認フロー・commit メッセージ・dry-run 配線

**Files:**
- Modify: `scripts/claude-settings-backport.sh`(`select_keys`/`commit_message`/`main` 前半)
- Modify: `scripts/tests/test-claude-settings-backport.sh`(テスト追加)

**Interfaces:**
- Consumes: `diff_keys`, `apply_keys`, `is_drifted`
- Produces:
  - `select_keys <live-file> <key>...` — グローバル配列 `APPROVED` を設定。`$ALL=true` なら全キー、そうでなければ `/dev/tty` から `y/N`。
  - `commit_message` — `chore(claude): backport settings.json (k1, k2)` を出力(`APPROVED` を `, ` 連結)。

- [ ] **Step 1: 失敗するテストを書く**

Append(`echo "PASS=..."` の前):
```bash
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
```

- [ ] **Step 2: 実行して失敗を確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: FAIL — `select_keys: command not found`。

- [ ] **Step 3: 実装**

`apply_keys()` の下に追加:
```bash
# 差分候補から取り込むキーを APPROVED に決める。$ALL なら全採用、他は対話。
select_keys() {
  local live="$1"; shift
  APPROVED=()
  local k ans
  for k in "$@"; do
    if $ALL; then APPROVED+=("$k"); continue; fi
    printf '\n=== %s (live value) ===\n' "$k"
    jq --arg k "$k" '.[$k]' "$live"
    read -r -p "取り込む? [y/N] " ans </dev/tty || ans=""
    [[ "$ans" =~ ^[Yy]$ ]] && APPROVED+=("$k")
  done
}

# APPROVED を ", " 連結した commit メッセージ。
commit_message() {
  local IFS=', '
  printf 'chore(claude): backport settings.json (%s)' "${APPROVED[*]}"
}
```

`main()` を差し替え(git/gh 前まで配線、`--dry-run`/差分ゼロ/no-op を処理):
```bash
main() {
  parse_args "$@"
  command -v jq >/dev/null 2>&1 || { log_error "jq not found"; exit 1; }
  [ -f "$LIVE" ] || { log_error "live settings.json not found: $LIVE"; exit 1; }
  [ -f "$REPO_REL" ] || { log_error "repo settings.json not found: $REPO_REL"; exit 1; }

  if ! is_drifted; then
    log_info "settings.json は symlink(drift なし)。取り込むものはありません。"; exit 0
  fi

  local keys=() line; while IFS= read -r line; do keys+=("$line"); done < <(diff_keys "$LIVE" "$REPO_REL")
  if [ "${#keys[@]}" -eq 0 ]; then
    log_success "差分なし。取り込むものはありません。"; exit 0
  fi

  if $DRY_RUN; then
    log_info "差分候補(--dry-run):"; printf '  - %s\n' "${keys[@]}"; exit 0
  fi

  select_keys "$LIVE" "${keys[@]}"
  if [ "${#APPROVED[@]}" -eq 0 ]; then
    log_info "取り込むキーが選択されませんでした。"; exit 0
  fi

  apply_keys "$REPO_REL" "$LIVE" "${APPROVED[@]}"
  log_success "repo に反映しました: ${APPROVED[*]}"
  git --no-pager diff -- "$REPO_REL" || true

  if $EDIT; then "${EDITOR:-vi}" "$REPO_REL"; fi

  # git/gh 連携は Task 5,6 で追加
}
```

- [ ] **Step 4: テストが通ることを確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: PASS — `FAIL=0`。

- [ ] **Step 5: `--dry-run` を実機で確認(副作用なし)**

Run: `bash scripts/claude-settings-backport.sh --dry-run`
Expected: symlink なら「drift なし」、drift 中なら差分候補一覧。いずれも repo・git 無変更(`git status` がクリーンのまま)。

- [ ] **Step 6: commit**

```bash
git add scripts/claude-settings-backport.sh scripts/tests/test-claude-settings-backport.sh
git commit -m "feat(claude): interactive approval, dry-run, and merge wiring"
```

---

### Task 5: ブランチ準備・commit・push・PR 作成(`--no-pr`)

**Files:**
- Modify: `scripts/claude-settings-backport.sh`(`prepare_branch`/`commit_and_push`/`open_pr`/`main` 後半)
- Modify: `scripts/tests/test-claude-settings-backport.sh`(gh stub テスト追加)

**Interfaces:**
- Consumes: `commit_message`(Task 4), `APPROVED`
- Produces:
  - `prepare_branch` — `origin/main` を fetch し、未 merge の同名リモートブランチがあればそれを、無ければ `origin/main` を base に `git checkout -B "$BRANCH"`。
  - `commit_and_push` — `git add "$REPO_REL"` → `git commit -m "$(commit_message)"` → `$NO_PR` でなければ `git push -u origin "$BRANCH"`。
  - `open_pr` — 既存 PR が無ければ `gh pr create --base main --head "$BRANCH"`、あれば何もしない(push で更新)。PR URL を `log_info`。

- [ ] **Step 1: 失敗するテストを書く**(gh を stub 化し `open_pr` の呼び出しを検証)

Append(`echo "PASS=..."` の前):
```bash
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
```

- [ ] **Step 2: 実行して失敗を確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: FAIL — `open_pr: command not found`。

- [ ] **Step 3: 実装**

`commit_message()` の下に追加:
```bash
prepare_branch() {
  git fetch origin main --quiet
  if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    git checkout -B "$BRANCH" "origin/$BRANCH" --quiet
  else
    git checkout -B "$BRANCH" origin/main --quiet
  fi
}

commit_and_push() {
  git add "$REPO_REL"
  git commit -m "$(commit_message)" --quiet
  $NO_PR && { log_success "commit まで完了(--no-pr)。"; return 0; }
  git push -u origin "$BRANCH" --quiet
}

open_pr() {
  if gh pr view "$BRANCH" >/dev/null 2>&1; then
    log_info "既存 PR を更新: $(gh pr view "$BRANCH" --json url -q .url 2>/dev/null)"
  else
    local url
    url="$(gh pr create --base main --head "$BRANCH" \
      --title "chore(claude): backport settings.json" \
      --body "Automated backport of live settings.json changes into the repo." 2>/dev/null | tail -1)"
    log_info "PR を作成: $url"
  fi
}
```

`main()` 末尾の `# git/gh 連携は Task 5,6 で追加` を差し替え(`--no-pr` のときは `gh` を要求しない):
```bash
  if ! $NO_PR; then command -v gh >/dev/null 2>&1 || { log_error "gh not found (needed for PR)"; exit 1; }; fi
  prepare_branch
  commit_and_push
  $NO_PR && exit 0
  open_pr
  # PR マージは Task 6 で追加
```

- [ ] **Step 4: テストが通ることを確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: PASS — `FAIL=0`。

- [ ] **Step 5: commit**

```bash
git add scripts/claude-settings-backport.sh scripts/tests/test-claude-settings-backport.sh
git commit -m "feat(claude): branch prep, commit/push, and PR creation"
```

---

### Task 6: PR マージ + フォールバック(`--no-merge`)

**Files:**
- Modify: `scripts/claude-settings-backport.sh`(`merge_pr`/`main` 末尾)
- Modify: `scripts/tests/test-claude-settings-backport.sh`(gh stub でマージ成功/失敗を検証)

**Interfaces:**
- Consumes: `BRANCH`
- Produces: `merge_pr` — `gh pr merge "$BRANCH" --merge --delete-branch`。成功で `log_success`、失敗で `log_warning` + PR URL を出し **return 0**(fatal にしない)。

- [ ] **Step 1: 失敗するテストを書く**

Append(`echo "PASS=..."` の前):
```bash
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
```

- [ ] **Step 2: 実行して失敗を確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: FAIL — `merge_pr: command not found`。

- [ ] **Step 3: 実装**

`open_pr()` の下に追加:
```bash
# PR をマージ。失敗しても PR は残し fatal にしない(--no-merge 相当に退避)。
merge_pr() {
  if gh pr merge "$BRANCH" --merge --delete-branch; then
    log_success "PR をマージしました。"
  else
    log_warning "PR マージに失敗。PR を残します: $(gh pr view "$BRANCH" --json url -q .url 2>/dev/null)"
  fi
  return 0
}
```

`main()` 末尾の `# PR マージは Task 6 で追加` を差し替え:
```bash
  $NO_MERGE && { log_success "PR 作成まで完了(--no-merge)。"; exit 0; }
  merge_pr
```

- [ ] **Step 4: テストが通ることを確認**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: PASS — `FAIL=0`。

- [ ] **Step 5: commit**

```bash
git add scripts/claude-settings-backport.sh scripts/tests/test-claude-settings-backport.sh
git commit -m "feat(claude): merge PR with graceful fallback"
```

---

### Task 7: `just claude backport` recipe + 実行権限

**Files:**
- Modify: `just/claude.just`
- Modify: `scripts/claude-settings-backport.sh`(実行ビット)

**Interfaces:**
- Consumes: `scripts/claude-settings-backport.sh`

- [ ] **Step 1: recipe を追加**

`just/claude.just` の `plugins:` recipe の下に追記:
```just
# Backport live settings.json into the repo, open a PR and merge it (interactive, live->repo)
backport *ARGS:
    ./scripts/claude-settings-backport.sh {{ARGS}}
```

- [ ] **Step 2: 実行ビットを付与**

```bash
chmod +x scripts/claude-settings-backport.sh
```

- [ ] **Step 3: recipe が見えることを確認**

Run: `just --list claude`
Expected: `backport` と `plugins` が並ぶ。

- [ ] **Step 4: `--dry-run` を just 経由で確認**

Run: `just claude backport --dry-run`
Expected: Task 4 Step 5 と同じ挙動(repo・git 無変更)。

- [ ] **Step 5: 全テスト再実行**

Run: `bash scripts/tests/test-claude-settings-backport.sh`
Expected: `FAIL=0`。

- [ ] **Step 6: commit**

```bash
git add just/claude.just scripts/claude-settings-backport.sh
git commit -m "feat(claude): add 'just claude backport' recipe"
```

---

## 統合確認(全タスク後、手動・任意)

drift が実在する環境で一度だけ通しで確認する(実 PR が作られる点に注意):
- `just claude backport --no-merge` で PR 作成まで → GitHub で内容確認 → 手動マージ、または
- `just claude backport` で PR マージまで一気通貫 → `just apply` で symlink 復元を確認。

## Self-Review(この計画の作成者チェック済み)

- **Spec coverage**: drift 判定 / 差分検出 / 承認 / マージ / commit・push・PR / マージ・フォールバック / フラグ(dry-run・no-pr・no-merge・all・edit)/ エラー処理 / just recipe — すべて Task 1–7 に対応。
- **Placeholder scan**: 各コード step に実コードあり。`# 後続タスクで肉付け` 等は骨格の意図的な差し替えポイントで、同タスク内で解消。
- **Type consistency**: `is_drifted`/`diff_keys`/`apply_keys`/`select_keys`/`commit_message`/`prepare_branch`/`commit_and_push`/`open_pr`/`merge_pr` の名称・引数はタスク間で一致。グローバル `APPROVED`/`BRANCH`/`REPO_REL`/フラグ名も一貫。

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

main() {
  parse_args "$@"
  : # 後続タスクで肉付け
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi

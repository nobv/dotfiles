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
    if ! jq --arg k "$k" --argjson v "$v" '.[$k] = $v' "$tmp" > "$tmp.next"; then
      rm -f "$tmp" "$tmp.next"
      log_error "failed to apply key: $k"
      return 1
    fi
    mv "$tmp.next" "$tmp"
  done
  mv "$tmp" "$repo"
}

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
# 注: `local IFS=', '; "${APPROVED[*]}"` は bash では IFS の先頭 1 文字(',')
# しか区切りに使われず ", " にならないため、printf '%s, ' + 末尾トリムで連結する。
commit_message() {
  local joined
  joined="$(printf '%s, ' "${APPROVED[@]}")"
  joined="${joined%, }"
  printf 'chore(claude): backport settings.json (%s)' "$joined"
}

prepare_branch() {
  if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    git fetch origin "$BRANCH" --quiet
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
      --body "Automated backport of live settings.json changes into the repo." | tail -1)"
    log_info "PR を作成: $url"
  fi
}

# PR をマージ。失敗しても PR は残し fatal にしない(--no-merge 相当に退避)。
merge_pr() {
  if gh pr merge "$BRANCH" --merge --delete-branch; then
    log_success "PR をマージしました。"
  else
    log_warning "PR マージに失敗。PR を残します: $(gh pr view "$BRANCH" --json url -q .url 2>/dev/null)"
  fi
  return 0
}

main() {
  parse_args "$@"
  command -v jq >/dev/null 2>&1 || { log_error "jq not found"; exit 1; }
  [ -f "$LIVE" ] || { log_error "live settings.json not found: $LIVE"; exit 1; }
  [ -f "$REPO_REL" ] || { log_error "repo settings.json not found: $REPO_REL"; exit 1; }
  jq empty "$LIVE" 2>/dev/null || { log_error "invalid JSON: $LIVE"; exit 1; }
  jq empty "$REPO_REL" 2>/dev/null || { log_error "invalid JSON: $REPO_REL"; exit 1; }

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

  # 対話プロンプト前に前提を確認して早期失敗させる(gh 不在・オフライン)。
  if ! $NO_PR; then command -v gh >/dev/null 2>&1 || { log_error "gh not found (needed for PR)"; exit 1; }; fi
  git fetch origin main --quiet

  select_keys "$LIVE" "${keys[@]}"
  if [ "${#APPROVED[@]}" -eq 0 ]; then
    log_info "取り込むキーが選択されませんでした。"; exit 0
  fi

  prepare_branch

  apply_keys "$REPO_REL" "$LIVE" "${APPROVED[@]}"
  if git diff --quiet -- "$REPO_REL"; then
    log_success "適用後の差分なし(既に反映済み)。取り込むものはありません。"
    exit 0
  fi
  log_success "repo に反映しました: ${APPROVED[*]}"
  git --no-pager diff -- "$REPO_REL" || true

  if $EDIT; then
    local -a editor
    read -r -a editor <<< "${EDITOR:-vi}"
    "${editor[@]}" "$REPO_REL"
  fi

  commit_and_push
  $NO_PR && exit 0
  open_pr
  $NO_MERGE && { log_success "PR 作成まで完了(--no-merge)。"; exit 0; }
  merge_pr
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi

# shell options
setopt hist_ignore_all_dups
setopt auto_pushd
setopt pushd_ignore_dups

# completions (compinit の後に実行される)
source <(kubectl completion zsh)
eval "$(workmux completions zsh)"

# tmux のペインボーダーに出る pane_title を管理する。
# 素の zsh は OSC タイトルを出さないため、放っておくと tmux のデフォルト値である
# ホスト名が出続け、さらに agent (claude/codex) 終了後はその agent が最後に設定した
# タスク名が残り続ける。実行中はコマンド名を、プロンプトに戻ったら空を送ることで、
# ボーダーが常に現在の状態を指すようにする。
# tmux 外ではボーダーが無いので、代わりにカレントディレクトリを端末タイトルに出す。
autoload -Uz add-zsh-hook

# printf の %s で渡す（print -P だとコマンド中の % がプロンプト展開されてしまう）
_pane_title() { printf '\e]2;%s\a' "$1" }
_pane_title_preexec() { _pane_title "${1//$'\n'/ }" }
_pane_title_precmd() {
  if [[ -n $TMUX ]]; then
    _pane_title ""
  else
    _pane_title "${(%):-%~}"
  fi
}

add-zsh-hook preexec _pane_title_preexec
add-zsh-hook precmd _pane_title_precmd

# functions

# workmux (instead of git worktree). `add` branches from origin/main, but
# workmux has no pre-add hook (post_create runs after the worktree exists),
# so fetch here first — otherwise it branches from a stale ref.
wm() {
  [[ "$1" == "add" ]] && git fetch origin --quiet
  command workmux "$@"
}

g() {
  local REPO
  REPO=$(ghq list | sort -u | fzf --height 40% --reverse --border)
  [ -z "$REPO" ] && return
  for GHQ_ROOT in $(ghq root -all); do
    [ -d "$GHQ_ROOT/$REPO" ] && cd "$GHQ_ROOT/$REPO" && return
  done
}

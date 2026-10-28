# shell options
setopt hist_ignore_all_dups
setopt auto_pushd
setopt pushd_ignore_dups

# completions (compinit の後に実行される)
source <(kubectl completion zsh)
eval "$(workmux completions zsh)"
# wm is a wrapper (see below), so it doesn't inherit workmux's completion by name
compdef wm=workmux

# tmux のペインボーダーに出る pane_title を管理する。
# 素の zsh は OSC タイトルを出さないため、放っておくと tmux のデフォルト値である
# ホスト名が出続け、さらに agent (claude/codex) 終了後はその agent が最後に設定した
# タスク名が残り続ける。実行中はコマンド名を、プロンプトに戻ったら空白 1 文字を送ることで、
# ボーダーが常に現在の状態を指すようにする。
# 空文字にしないのは、tmux-resurrect が保存時にタブ区切りを `IFS=$'\t' read` で読み、
# 空の pane_title の列が詰まって作業ディレクトリが復元されなくなるため。
# tmux 外ではボーダーが無いので、代わりにカレントディレクトリを端末タイトルに出す。
autoload -Uz add-zsh-hook

# printf の %s で渡す（print -P だとコマンド中の % がプロンプト展開されてしまう）
_pane_title() { printf '\e]2;%s\a' "$1" }
_pane_title_preexec() { _pane_title "${1//$'\n'/ }" }
_pane_title_precmd() {
  if [[ -n $TMUX ]]; then
    _pane_title " "
  else
    _pane_title "${(%):-%~}"
  fi
}

add-zsh-hook preexec _pane_title_preexec
add-zsh-hook precmd _pane_title_precmd

# functions

# workmux は初期プロンプトを `claude -- "<prompt>"` で渡す。`--` が argv に残ると
# tmux-assistant-resurrect が復元時に `claude -- --resume <id>` を組み立て、
# --resume がプロンプトになって新しいセッションが始まる。
# `--` の後がプロンプト 1 つで、`-` で始まらないときだけ `--` を外す。
claude() {
  local i=${@[(ie)--]}
  if (( i == $# - 1 )) && [[ ${@[-1]} != -* ]]; then
    set -- "${@[1,i-1]}" "${@[-1]}"
  fi
  command claude "$@"
}

# workmux (instead of git worktree). `add` branches from origin/main, but
# workmux has no pre-add hook (post_create runs after the worktree exists),
# so fetch here first — otherwise it branches from a stale ref.
wm() {
  [[ "$1" == "add" ]] && git fetch origin --quiet
  command workmux "$@"
}

# wmp <number|url> [add flags...] -> wm add --pr <number|url> [add flags...]
wmp() {
  wm add --pr "$@"
}

g() {
  local REPO
  REPO=$(ghq list | sort -u | fzf --height 40% --reverse --border)
  [ -z "$REPO" ] && return
  for GHQ_ROOT in $(ghq root -all); do
    [ -d "$GHQ_ROOT/$REPO" ] && cd "$GHQ_ROOT/$REPO" && return
  done
}

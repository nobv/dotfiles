# shell options
setopt hist_ignore_all_dups
setopt auto_pushd
setopt pushd_ignore_dups

# completions (compinit の後に実行される)
source <(kubectl completion zsh)
eval "$(workmux completions zsh)"

# functions
g() {
  local REPO
  REPO=$(ghq list | sort -u | fzf --height 40% --reverse --border)
  [ -z "$REPO" ] && return
  for GHQ_ROOT in $(ghq root -all); do
    [ -d "$GHQ_ROOT/$REPO" ] && cd "$GHQ_ROOT/$REPO" && return
  done
}

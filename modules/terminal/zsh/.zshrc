# Extra commands that should be added to .zshrc. 

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# history
setopt hist_ignore_all_dups
setopt auto_pushd
setopt pushd_ignore_dups

# exports
export DOTFILES=$HOME/.dotfiles
# export ZSH=$DOTFILES/modules/term/zsh/bin

## https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1030877541
# export NIX=$HOME/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin
# export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels
# export PATH=$VOLTA_HOME/bin:$HOME/.cargo/bin:/usr/local/bin:$DOTFILES/bin:$DOOM:$ZSH:$NIX:$NPM_PACKAGES:$PATH
# export VOLTA_HOME="$HOME/.volta"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"


export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# typeset -U PATH

# typeset -U fpath
# fpath=($DOTFILES/modules/term/zsh/completions $fpath)
# autoload -U +X compinit && compinit
# autoload -U +X bashcompinit && bashcompinit


# for kubernetes
source <(kubectl completion zsh)

g() {
  local REPO
  REPO=$(ghq list | sort -u | fzf --height 40% --reverse --border)
  [ -z "$REPO" ] && return
  for GHQ_ROOT in $(ghq root -all); do
    [ -d "$GHQ_ROOT/$REPO" ] && cd "$GHQ_ROOT/$REPO" && return
  done
}


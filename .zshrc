
export GOPATH=$HOME/src
export PATH=$PATH:$GOPATH/bin

# History
# TODO: history share
export HISTSIZE=99999
export HISTFILESIZE=99999


if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# zplug setting
if [[ -f ~/.zplug/init.zsh ]]; then
  export ZPLUG_LOADFILE=~/.zsh/zplug.zsh
  source ~/.zplug/init.zsh

  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
      echo; zplug install
    fi
    echo
  fi
  zplug load
fi

# Start tmux when zsh starts
[[ -z "$TMUX" && ! -z "$PS1" ]] && exec tmux

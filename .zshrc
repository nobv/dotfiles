
export PATH="/usr/local/bin:$PATH"
export GOPATH=$HOME/src
export PATH=$PATH:$GOPATH/bin

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

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

[[ -z "$TMUX" && ! -z "$PS1" ]] && exec tmux

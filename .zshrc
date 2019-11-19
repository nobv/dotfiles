# Global
## Dotfile
export DOTFILES=$HOME/.dotfiles
export DOOM=$HOME/.emacs.d/bin
export PATH="/usr/local/bin:$PATH"
export PATH=$PATH:$DOTFILES/bin:$DOOM
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM="xterm-256color"

## anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

## Go
export GOPATH=$HOME/src
export PATH=$PATH:$GOPATH/bin
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

## Rust
export PATH="$HOME/.cargo/bin:$PATH"


## Language
export LANG=en_US.UTF-8

## Stack
export PATH=~/.local/bin:$PATH
export PATH=$(stack path --compiler-bin):$PATH

## direnv
export EDITOR=emacs
eval "$(direnv hook zsh)"

## History
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

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
#[[ -z "$TMUX" && ! -z "$PS1" ]] && exec tmux

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nobv/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/nobv/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/nobv/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/nobv/google-cloud-sdk/completion.zsh.inc'; fi

# auto-completion for stack
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
eval "$(stack --bash-completion-script stack)"

# Dotfile
export DOTFILES=$HOME/.dotfiles
export DOOM=$HOME/.emacs.d/doom-emacs/bin
export PATH=$DOTFILES/bin:$DOOM:$PATH
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM="xterm-256color"

# zsh
typeset -U fpath
fpath=($DOTFILES/.zsh/completions $fpath)
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

bindkey -v
export PATH=$DOTFILES/.zsh/bin:$PATH

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

# brew
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# Go
export GOPATH=$HOME/src
export PATH=$GOPATH/bin:$PATH
export PATH="$GOROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
## starship
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.starship

# Haskell
## Stack
export PATH=~/.local/bin:$PATH
export PATH=$(stack path --compiler-bin):$PATH
eval "$(stack --bash-completion-script stack)"
# ghcup-env
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"


# direnv
export EDITOR=emacsclient
eval "$(direnv hook zsh)"

# llvm
export PATH="/usr/local/opt/llvm/bin:$PATH"

# node
export PATH="$HOME/.anyenv/envs/nodenv/shims/node:$PATH"

# enhancd
export ENHANCD_HOOK_AFTER_CD=ll
export ENHANCD_FILTER="fzf:peco"

# Terraform
complete -o nospace -C /usr/local/Cellar/tfenv/1.0.2/versions/0.12.20/terraform terraform

# Android
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# navi
source <(navi widget zsh)

# aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# poetry
# fpath+=~/.zfunc
# poetry completions zsh > ~/.zfunc/_poetry

# zlib
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# kubectl
source <(kubectl completion zsh)


# zplug
# if [[ -f ~/.zplug/init.zsh ]]; then
#   export ZPLUG_LOADFILE=~/.zsh/zplug.zsh
#   source ~/.zplug/init.zsh

#   if ! zplug check --verbose; then
#     printf "Install? [y/N]: "
#     if read -q; then
#       echo; zplug install
#     fi
#     echo
#   fi
#   zplug load
# fi

# Start tmux when zsh starts
#[[ -z "$TMUX" && ! -z "$PS1" ]] && exec tmux

# GCP
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/nobv/.anyenv/envs/pyenv/versions/anaconda3-2021.05/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/nobv/.anyenv/envs/pyenv/versions/anaconda3-2021.05/etc/profile.d/conda.sh" ]; then
        . "/Users/nobv/.anyenv/envs/pyenv/versions/anaconda3-2021.05/etc/profile.d/conda.sh"
    else
        export PATH="/Users/nobv/.anyenv/envs/pyenv/versions/anaconda3-2021.05/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

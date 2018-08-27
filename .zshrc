
export PATH="/usr/local/bin:$PATH"
export GOPATH=$HOME/src
export PATH=$PATH:$GOPATH/bin

alias g='cd $(ghq root)/$(ghq list | peco)'

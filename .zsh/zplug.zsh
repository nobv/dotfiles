zplug "zplug/zplug", hook-build:'zplug --self-manage'

zplug "b4b4r07/emoji-cli"

#zplug "themes/wedisagree", from:oh-my-zsh

zplug "bhilburn/powerlevel9k", use:"powerlevel9k.zsh-theme", as:theme, if:"source ~/.powerlevel9k"

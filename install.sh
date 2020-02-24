#!/bin/bash

for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".bashrc" ]] && continue
    [[ "$f" == ".emacs.d" ]] && continue

    if [[ "$f" == ".starship.toml" ]]; then
        ln -snfv ~/.dotfiles/"$f" ~/.starship
    fi

    ln -snfv ~/.dotfiles/"$f" ~/
done

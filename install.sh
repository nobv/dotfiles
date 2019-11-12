#!/bin/bash

for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".bashrc" ]] && continue
    [[ "$f" == ".emacs.d" ]] && continue

    #echo "$f"
    ln -snfv ~/.dotfiles/"$f" ~/
done

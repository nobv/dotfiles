#!/bin/zsh

git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d/spacemacs

brew install hunspell

curl -OL https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_US.aff > ~/Library/Spelling/en_US.aff
curl -OL https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_US.dic > ~/Library/Spelling/en_US.dic

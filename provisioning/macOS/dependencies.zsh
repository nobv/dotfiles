#!/bin/zsh

xcode-select --install &> /dev/null

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap homebrew/cask-versions

brew install git

#!/bin/bash

# if macOS
## update macOS
softwareupdate --install --all

# install xcode-select
xcode-select —install
# or install XCode.app

# install nix
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon
exec $SHELL -l
nix-shell -p nix-info --run "nix-info -m"

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
home-manager switch
nix-shell '<darwin>' -A installer
darwin-rebuild switch
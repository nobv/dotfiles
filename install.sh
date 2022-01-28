#!/bin/bash

# if macOS
## update macOS
sudo softwareupdate --install --all --install-rosetta

# install nix
sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon

# どうにかしてシェルを再起動する (exec $SHELL -l だと後続のコマンドが実行されない)
exec $SHELL -l
nix-shell -p nix-info --run "nix-info -m"

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# どうにかしてシェルを再起動する (exec $SHELL -l だと後続のコマンドが実行されない)
# exec $SHELL -l

# dotfiles を git clone

# copy dotfiles to
ln -snfv $HOME/.dotfiles/nix/home.nix $HOME/.config/nixpkgs
nix-shell '<home-manager>' -A install
home-manager switch

# 先に AppStoreにログインしておく
## homebrew インストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ln -snfv $HOME/.dotfiles/nix/darwin-configuration.nix $HOME/.nixpkgs
nix-shell '<darwin>' -A installer
darwin-rebuild switch


# 

# doom
ln -snfv $HOME/.dotfiles/.doom.d $HOME/.config/doom
git clone https://github.com/hlissner/doom-emacs ~/.config/doom-emacs

# spacemacs
ln -snfv $HOME/.dotfiles/.spacemacs.d $HOME/.config/spacemacs
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.config/spacemacs

# vscode 
#!/bin/bash

# if macOS
## update macOS
sudo softwareupdate --install --all --install-rosetta --agree-to-license
xcode-select --install

# install nix
# sh <(curl -L https://nixos.org/nix/install)
# sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume --daemon

zsh
nix-shell -p nix-info --run "nix-info -m"

# export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
# nix-channel --add https://nixos.org/channels/nixpkgs-21.11-darwin nixpkgs-stable
# nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
# nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update


/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git clone git@github.com:nobv/dotfiles.git
nix build .#darwinConfigurations.macmini.system --experimental-features "nix-command flakes"


# error: Directory /run does not exist, aborting activation` が出たら
printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
# /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util-B # For Catalina
/System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util-t #For Big Sur and later


# どうにかしてシェルを再起動する (exec $SHELL -l だと後続のコマンドが実行されない)
# exec $SHELL -l

# dotfiles を git clone

# copy dotfiles to
# ln -snfv $HOME/.dotfiles/nix/home.nix $HOME/.config/home-manager
# nix-shell '<home-manager>' -A install
# home-manager switch
#
# 先に AppStoreにログインしておく
## homebrew インストール
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# ln -snfv $HOME/.dotfiles/nix/darwin-configuration.nix $HOME/.nixpkgs
# nix-shell '<darwin>' -A installer
# darwin-rebuild switch
#

# 

# doom
# ln -snfv $HOME/.dotfiles/modules/editor/emacs/.doom.d $HOME/.config/doom
# git clone https://github.com/hlissner/doom-emacs ~/.config/doom-emacs
#
# spacemacs
# ln -snfv $HOME/.dotfiles/modules/editor/emacs/.spacemacs.d $HOME/.spacemacs.d
# git clone https://github.com/syl20bnr/spacemacs ~/.config/spacemacs
#
# vscode 

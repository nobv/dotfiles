MACHINE := env("DOTFILES_MACHINE", "macbook")

default:
    @just --list

dry-run:
    darwin-rebuild switch --flake .#{{MACHINE}} --dry-run

switch:
    sudo darwin-rebuild switch --flake .#{{MACHINE}}

check:
    nix flake check

fmt:
    nix fmt

update:
    nix flake update

update-input INPUT:
    nix flake lock --update-input {{INPUT}}

dev:
    nix develop

show:
    nix flake show

modules:
    ./scripts/enable-module.sh {{MACHINE}}

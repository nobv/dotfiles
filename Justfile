mod nix 'just/nix.just'
mod git 'just/git.just'
mod apm 'just/apm.just'
mod claude 'just/claude.just'
mod den 'just/den.just'
mod alfred 'modules/productivity/alfred/alfred.just'
mod crit 'modules/development/vcs/crit/crit.just'

# List all recipes
default:
    @just --list

# Full apply: fast-forward main, check drift, rebuild, then sync apm, Claude plugins, Crit and Alfred
apply:
    just git sync
    just claude drift
    just nix switch
    just apm sync
    just claude plugins
    just crit sync
    just alfred sync

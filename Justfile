mod nix 'just/nix.just'
mod git 'just/git.just'
mod apm 'just/apm.just'
mod claude 'just/claude.just'
mod den 'just/den.just'
mod alfred 'modules/productivity/alfred/alfred.just'

# List all recipes
default:
    @just --list

# Full apply: fast-forward main, rebuild, then sync apm packages, Claude Code plugins and Alfred workflows
apply:
    just git sync
    just nix switch
    just apm sync
    just claude plugins
    just alfred sync

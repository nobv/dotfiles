mod nix 'just/nix.just'
mod git 'just/git.just'
mod apm 'just/apm.just'
mod claude 'just/claude.just'
mod den 'just/den.just'

# List all recipes
default:
    @just --list

# Full apply: fast-forward main, rebuild, then sync apm packages and Claude Code plugins
apply:
    just git sync
    just nix switch
    just apm sync
    just claude plugins

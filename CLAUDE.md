# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Build system configuration: `nix build .#darwinConfigurations.<machine-name>.system`
- Apply configuration: `./result/sw/bin/darwin-rebuild switch --flake .#<machine-name>`
- Create new machine: `./machines/create-machine.sh <machine-name>`

## Code Style Guidelines
- Follow Nix expression style for .nix files
- Organize new modules in appropriate subdirectories (app/, editor/, lang/, tools/)
- Maintain module structure with default.nix as entry point
- Use descriptive names for configuration options
- Include comments for complex expressions
- Keep indentation consistent (2 spaces)
- Group related configuration options together
- Follow existing patterns when creating new configurations

## Commit Guidelines
- Use Conventional Commits: `<type>(<optional scope>): <description>`
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Examples: `feat(homebrew): add packages`, `fix(wezterm): correct config`, `chore: update .gitignore`

## Repository Structure
- flake.nix: Main entry point
- darwin/: Base darwin configuration
- machines/: Machine-specific configurations
- modules/: Reusable configuration modules
- overlays/: Nixpkgs overlays
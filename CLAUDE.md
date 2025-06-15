# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview
This is a Nix Darwin configuration using flakes and Home Manager for macOS system and user environment management. The architecture consists of:

- **Flake-based configuration** (`flake.nix`) with machine-specific Darwin configurations
- **Option-based module system** where all modules use `options.modules.<category>.<name>.enable` pattern
- **Self-contained machine configs** in `machines/` that include both Darwin and Home Manager settings
- **Auto-discovery system**: Modules are automatically imported from the modules directory
- **Conditional module loading** via options system for clean, maintainable configurations

## Build Commands
- Check flake: `nix flake check`
- Build system configuration: `nix build .#darwinConfigurations.<machine>.system`
- Apply configuration: `darwin-rebuild switch --flake .#<machine>`
- Update flake inputs: `nix flake update`
- Show flake info: `nix flake show`

## Installation Commands
- One-liner install: `bash -c "$(curl -L https://raw.githubusercontent.com/nobv/dotfiles/master/install)"`
- Manual install: `./setup.sh -m <machine>` (after cloning repo)
- Skip Homebrew: `./setup.sh -m <machine> --skip-homebrew`

## Machine Configurations
Available machine configurations:
- `macbook` - Development-focused setup for MacBook (tmux, docker, python, etc.)
- `macmini` - Desktop setup for Mac Mini (emacs, lighter dev tools)
- `work` - Full development stack for work environment

Example usage:
- `darwin-rebuild switch --flake .#macbook`
- `darwin-rebuild switch --flake .#work`
- `darwin-rebuild switch --flake .#macmini`

## Username Configuration
- Username is automatically detected from `$USER` environment variable
- Falls back to "nobv" if `$USER` is empty (e.g., during build)
- No longer hardcoded in flake.nix

## Module System Architecture
- **Self-contained machine configs**: Each `machines/<machine>/default.nix` contains complete Darwin + Home Manager config
- **Centralized module discovery**: Module auto-discovery logic is shared in `flake.nix` and applied to all machines
- **Module structure**: Each module in `modules/` defines `options.modules.<category>.<name>` and conditional `config`
- **Complex modules**: Some modules (like homebrew) auto-generate options from data structures
- **DRY principle**: No code duplication between machine configs

## Module Development Guidelines
- **Module pattern**: Follow the established pattern: function signature → `with lib;` → `cfg` binding → `options` → `config = mkIf cfg.enable`
- **Option naming**: Use `options.modules.<category>.<name>.enable = mkEnableOption "<description>"`
- **Conditional config**: Wrap all functionality in `config = mkIf cfg.enable { ... }`
- **File organization**: Place modules in appropriate subdirectories (app/, editor/, lang/, tools/, term/, font/, checkers/)
- **Complex modules**: For modules with many sub-options (like homebrew), consider auto-generating options from data structures
- **Adding new modules**: Simply create the module in appropriate directory - it will be auto-discovered

## Commit Guidelines
- Use Conventional Commits: `<type>(<optional scope>): <description>`
- Keep commit messages to a single line only
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Examples: `feat(homebrew): add packages`, `fix(wezterm): correct config`, `chore: update .gitignore`

## Repository Structure
- `flake.nix`: Main entry point with auto-discovery logic
- `install`: One-liner bootstrap script (curl-compatible)
- `setup.sh`: Full installation script (sources shared utilities)
- `scripts/lib.sh`: Shared utilities (logging, macOS check, constants)
- `machines/`: Machine-specific configurations (each has default.nix, darwin.nix, home.nix)
- `modules/`: Reusable configuration modules organized by category
  - `app/`: Application configurations (Chrome, iTerm2, etc.)
  - `editor/`: Text editors (vim, emacs, neovim, vscode)
  - `lang/`: Programming language environments
  - `tools/`: Development tools and CLI utilities
  - `term/`: Terminal and shell configurations
  - `font/`: Font management
  - `checkers/`: Linting and code quality tools
- `overlays/`: Nixpkgs overlays for custom packages

## Installation Script Architecture
- `install`: Bootstrap script that handles system preparation (Xcode CLT, system updates) before repo cloning
- `setup.sh`: Main installer that handles Nix installation, Homebrew, and Darwin configuration
- Both scripts use shared utilities from `scripts/lib.sh` for consistent logging and error handling
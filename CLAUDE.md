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
- **Test configuration (REQUIRED)**: `darwin-rebuild switch --flake .#<machine> --dry-run`
- Apply configuration: `darwin-rebuild switch --flake .#<machine>`
- Update flake inputs: `nix flake update`
- Show flake info: `nix flake show`

**IMPORTANT**: Always run `--dry-run` before applying configuration changes to validate the build and prevent system breakage.

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
- Each machine has a `config.nix` file containing username configuration
- Files located at `machines/<machine>/config.nix` with format `{ username = "your-username"; }`
- Usernames are read during flake evaluation and passed via specialArgs
- Error thrown if config.nix file is missing for a machine
- Username setting is now centralized and no longer duplicated across files

## Module System Architecture
- **Self-contained machine configs**: Each `machines/<machine>/default.nix` contains complete Darwin + Home Manager config
- **Centralized module discovery**: Module auto-discovery logic is shared in `flake.nix` and applied to all machines
- **Module structure**: Each module in `modules/` defines `options.modules.<category>.<name>` and conditional `config`
- **Individual app modules**: All applications are split into individual modules for fine-grained control
- **Homebrew dependency**: Apps using Homebrew wrap their config with `mkIf (config.modules.tools.homebrew.enable or false)`
- **Machine config structure**: Each machine has `default.nix` (module selections), `darwin.nix` (system config), `home.nix` (user config), and `config.nix` (username)
- **DRY principle**: No code duplication between machine configs

## Module Development Guidelines
- **Module pattern**: Follow the established pattern: function signature → `with lib;` → `cfg` binding → `options` → `config = mkIf cfg.enable`
- **Option naming**: Use `options.modules.<category>.<name>.enable = mkEnableOption "<description>"`
- **Conditional config**: Wrap all functionality in `config = mkIf cfg.enable { ... }`
- **Homebrew dependency**: For modules using Homebrew, wrap homebrew config with `mkIf (config.modules.system.homebrew.enable or false)`
- **File organization**: Place modules in appropriate functional categories (see Module Categories below)
- **Adding new modules**: Simply create the module in appropriate category directory - it will be auto-discovered

## Commit Guidelines
- Use Conventional Commits: `<type>(<optional scope>): <description>`
- Keep commit messages to a single line only
- **Do not include** Claude Code attribution (`🤖 Generated with...` or `Co-Authored-By: Claude`) in commit messages
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Examples: `feat(homebrew): add packages`, `fix(wezterm): correct config`, `chore: update .gitignore`

## Repository Structure
- `flake.nix`: Main entry point with auto-discovery logic
- `install`: One-liner bootstrap script (curl-compatible)
- `setup.sh`: Full installation script (sources shared utilities)
- `scripts/lib.sh`: Shared utilities (logging, macOS check, constants)
- `machines/`: Machine-specific configurations (each has default.nix, darwin.nix, home.nix, config.nix)
- `modules/`: Reusable configuration modules organized by functional categories
- `overlays/`: Nixpkgs overlays for custom packages

## Module Categories
Modules are organized by function for intuitive discovery and management:
- `ai/`: AI applications (claude, chatgpt, perplexity, poe)
- `browsers/`: Web browsers (chrome, firefox, arc, microsoft-edge)
- `communication/`: Communication apps (slack, discord, zoom, telegram, deepl)
- `design/`: Design and creative tools (figma, blender, miro)
- `development/`: Development tools and CLI utilities (docker, git, postman, xcode, aws, kubernetes, etc.)
- `editors/`: Text editors (vim, emacs, neovim, vscode, cursor, typora)
- `languages/`: Programming language environments (python, nodejs, rust, go, etc.)
- `media/`: Media and entertainment (spotify, kindle)
- `productivity/`: Productivity tools (notion, obsidian, things3, amphetamine, etc.)
- `security/`: Security tools (1password, wireguard)
- `system/`: System-level configurations (homebrew, aerospace, fonts)
- `terminal/`: Terminal and shell configurations (zsh, starship, wezterm)
- `utilities/`: General utilities (raycast, karabiner-elements, flux, etc.)
- `checkers/`: Code quality and linting tools

## Homebrew Module Architecture
The Homebrew module serves as the foundational package manager:
- **Base functionality**: Provides core Homebrew configuration (brewPrefix, onActivation, global settings)
- **Individual app modules**: Each application has its own module with conditional Homebrew dependencies
- **Dependency pattern**: Apps use `mkIf (config.modules.system.homebrew.enable or false)` to conditionally enable Homebrew packages
- **Fine-grained control**: Users can enable/disable individual applications while maintaining Homebrew as the foundation

## Module Configuration Examples
```nix
# Machine configuration using actual directory structure paths
modules = {
  # System tools (options.modules.system.*)
  system = {
    homebrew.enable = true;
    fonts.enable = true;
  };
  
  # Development tools (options.modules.development.*)
  development = {
    docker.enable = true;
    git.enable = true;
    tmux.enable = true;
  };
  
  # Programming languages (options.modules.languages.*)
  languages = {
    python.enable = true;
    nodejs.enable = true;
    rust.enable = true;
  };
  
  # Text editors (options.modules.editors.*)
  editors = {
    neovim.enable = true;
    vim.enable = true;
    jetbrains.enable = true;
  };
  
  # Terminal configuration (options.modules.terminal.*)
  terminal = {
    starship.enable = true;
    zsh.enable = true;
    wezterm.enable = true;
  };
  
  # Utilities (options.modules.utilities.*)
  utilities = {
    raycast.enable = true;
    karabiner-elements.enable = true;
  };
  
  # Security (options.modules.security.*)
  security = {
    "1password".enable = true;
  };
  
  # Code quality (options.modules.checkers)
  checkers.enable = true;
};
```

## Installation Script Architecture
- `install`: Bootstrap script that handles system preparation (Xcode CLT, system updates) before repo cloning
- `setup.sh`: Main installer that handles Nix installation, Homebrew, and Darwin configuration
- Both scripts use shared utilities from `scripts/lib.sh` for consistent logging and error handling
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview
This is a Nix Darwin configuration using flakes and Home Manager for macOS system and user environment management. The architecture consists of:

- **Flake-based configuration** (`flake.nix`) with machine-specific Darwin configurations
- **Option-based module system** where all modules use `options.modules.<category>.<name>.enable` pattern
- **Self-contained machine configs** in `machines/` that include both Darwin and Home Manager settings
- **Auto-discovery system**: Modules are automatically imported from the modules directory
- **Conditional module loading** via options system for clean, maintainable configurations

## Quick Start Commands

### Daily Development Commands
- **Test configuration (REQUIRED)**: `darwin-rebuild switch --flake .#<machine> --dry-run`
- Apply configuration: `darwin-rebuild switch --flake .#<machine>`
- Interactive module management: `./scripts/enable-module.sh [machine]`
- List all modules and status: `./scripts/enable-module.sh --list`

### Build and Validation Commands
- Check flake: `nix flake check`
- Build system configuration: `nix build .#darwinConfigurations.<machine>.system`
- Enter development shell: `nix develop`
- Show flake info: `nix flake show`

### Flake Management
- Update all inputs: `nix flake update`
- Update specific input: `nix flake lock --update-input <input-name>` (e.g., `nixpkgs`, `home-manager`)
- Show flake metadata: `nix flake metadata`

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
- `darwin-rebuild switch --flake .#macbook --dry-run` (test first)
- `darwin-rebuild switch --flake .#macbook` (then apply)
- `darwin-rebuild switch --flake .#work`
- `darwin-rebuild switch --flake .#macmini`

## Machine-Specific Configuration
- Each machine requires a `config.nix` file containing machine-specific settings
- Files located at `machines/<machine>/config.nix` with format `{ username = "your-username"; }`
- **These files are NOT tracked in git** (machine-specific settings should remain local)
- Configuration is generated from `templates/machine-config.nix.template` during setup

### Configuration Setup
**Automatic (Recommended):**
- Run `./setup.sh -m <machine>` - it will automatically generate `config.nix` from template
- Prompts for username and creates the file with proper format

**Manual Setup:**
1. Copy template: `cp templates/machine-config.nix.template machines/<machine>/config.nix`
2. Edit the file and replace placeholders:
   - `REPLACE_WITH_YOUR_USERNAME` → your actual username
   - Add any machine-specific settings as needed

### Configuration Format
```nix
{
  username = "your-username";  # Required: your system username
  # hostname = "custom-hostname";  # Optional: override default hostname
  # gitEmail = "work@company.com";  # Optional: machine-specific git email
}
```

## Interactive Module Management

The `scripts/enable-module.sh` script provides an interactive interface for managing modules:

**Usage:**
- Interactive mode: `./scripts/enable-module.sh` (auto-detects machine)
- Specific machine: `./scripts/enable-module.sh macbook`
- List all modules: `./scripts/enable-module.sh --list`
- Help: `./scripts/enable-module.sh --help`

**Features:**
- Browse modules by category (ai, browsers, development, etc.)
- View current status: enabled ✅, disabled ❌, or available 🆕
- Select multiple modules for bulk enable/disable
- Paginated display for categories with many modules
- Automatic validation of Nix configuration syntax
- Backup and rollback on validation failure

**Navigation:**
- Numbers: Select module to toggle
- Space: Toggle all visible modules on current page
- Enter: Apply selected changes
- c: Clear selections
- n/p: Next/previous page
- q: Back to categories

## Module System Architecture
- **Self-contained machine configs**: Each `machines/<machine>/default.nix` contains complete Darwin + Home Manager config
- **Centralized module discovery**: Module auto-discovery logic is shared in `flake.nix` and applied to all machines
- **Module structure**: Each module in `modules/` defines `options.modules.<category>.<name>` and conditional `config`
- **Individual app modules**: All applications are split into individual modules for fine-grained control
- **Homebrew dependency**: Apps using Homebrew wrap their config with `mkIf (config.modules.system.homebrew.enable or false)`
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

## Development Workflow

### Making Changes to Modules
1. Edit module files in `modules/<category>/<module>/default.nix`
2. Validate flake: `nix flake check`
3. Test changes: `darwin-rebuild switch --flake .#<machine> --dry-run`
4. Apply changes: `darwin-rebuild switch --flake .#<machine>`

### Adding New Modules
1. Create directory: `modules/<category>/<module-name>/`
2. Create `default.nix` following the module pattern (see Module Development Guidelines)
3. Module is auto-discovered - no flake.nix changes needed
4. Enable in machine config using `./scripts/enable-module.sh` or manually edit `machines/<machine>/default.nix`

### Testing Configuration Changes
Always use this sequence to prevent system breakage:
```bash
# 1. Validate flake syntax
nix flake check

# 2. Test the build without applying
darwin-rebuild switch --flake .#macbook --dry-run

# 3. If dry-run succeeds, apply the changes
darwin-rebuild switch --flake .#macbook
```

### Working with Development Shell
The repository includes a development shell with useful tools:
```bash
nix develop  # Enter shell with nixpkgs-fmt and nix-tree
```

Tools available in dev shell:
- `nixpkgs-fmt` - Format Nix files
- `nix-tree` - Interactively browse dependency tree

### Managing Dependencies
Update specific flake inputs when needed:
```bash
# Update nixpkgs only
nix flake lock --update-input nixpkgs

# Update home-manager only
nix flake lock --update-input home-manager

# Update all inputs
nix flake update
```

After updating, always test with `--dry-run` before applying.

## Troubleshooting

### Configuration Validation Failures
If `darwin-rebuild` fails with validation errors:
1. Check syntax: `nix flake check`
2. Review recent changes to module files
3. Verify balanced braces in edited `.nix` files
4. Check that module options follow correct naming: `options.modules.<category>.<name>.enable`

### Username Placeholder Error
Error: `Please update machines/<machine>/config.nix with your actual username`
- Edit `machines/<machine>/config.nix`
- Replace `REPLACE_WITH_YOUR_USERNAME` with your actual username
- Or run `./setup.sh -m <machine>` to regenerate config

### Module Not Found After Adding
If a new module isn't recognized:
1. Ensure `default.nix` exists in `modules/<category>/<module-name>/`
2. Run `nix flake check` to verify syntax
3. Check that category exists in the auto-discovery list in `flake.nix` (line 60-74)

### Homebrew Dependencies Not Installing
If apps requiring Homebrew don't install:
1. Verify `modules.system.homebrew.enable = true` in machine config
2. Check module wraps homebrew config with: `mkIf (config.modules.system.homebrew.enable or false)`
3. Run `darwin-rebuild` to apply Homebrew configuration

### Build Fails After Flake Update
If builds fail after updating inputs:
1. Check `flake.lock` for the changes: `git diff flake.lock`
2. Try updating inputs individually to isolate the issue
3. Rollback lock file: `git checkout flake.lock`
4. Report compatibility issues to the respective input repository

## Installation Script Architecture
- `install`: Bootstrap script that handles system preparation (Xcode CLT, system updates) before repo cloning
- `setup.sh`: Main installer that handles Nix installation, Homebrew, and Darwin configuration
- `scripts/enable-module.sh`: Interactive module management with validation
- `scripts/lib.sh`: Shared utilities for logging, macOS checks, and constants
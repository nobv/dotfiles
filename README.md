# Dotfiles

Nix Darwin configuration with Home Manager for macOS system and user environment management.

Uses the [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer) for reliable Nix installation with flakes and daemon support enabled by default.

## Quick Install

```bash
git clone https://github.com/nobv/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh -m <machine>  # Choose: macbook, macmini, or work
```

## Custom Installation

```bash
# Install with specific machine configuration
./install.sh -m macbook      # Development-focused setup
./install.sh -m work         # Full development stack
./install.sh -m macmini      # Desktop setup

# Skip system updates or Homebrew
./install.sh -s --skip-homebrew

# See all options
./install.sh --help
```

## Available Machine Configurations

- `macbook` - Development-focused (tmux, docker, python, kubernetes)
- `macmini` - Desktop setup (emacs, lighter dev tools, visible dock)
- `work` - Full development stack (all languages and tools)

## Switching Configurations

```bash
darwin-rebuild switch --flake ~/.dotfiles#<machine>
```

## Features

- **Reliable Nix Installation**: Uses Determinate Systems installer with flakes enabled by default
- **Machine-Specific Configurations**: Easy switching between different setups
- **Option-Based Modules**: Clean, maintainable module system with conditional loading
- **Home Manager Integration**: User environment management alongside system configuration
- **Automated Setup**: One-command installation with progress tracking and error handling

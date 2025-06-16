# Dotfiles

Modular Nix Darwin configuration with Home Manager for macOS system and user environment management.

Uses the [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer) for reliable Nix installation with flakes and daemon support enabled by default.

## Architecture

This configuration features a **fully modular architecture** with 74+ individual application modules organized into 14 functional categories for maximum flexibility and maintainability.

## Quick Install

One-liner installation:

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/nobv/dotfiles/master/install)"
```

Or manual installation:

```bash
git clone https://github.com/nobv/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh -m <machine>  # Choose: macbook, macmini, or work
```

## Custom Installation

```bash
# Install with specific machine configuration
./setup.sh -m macbook      # Development-focused setup
./setup.sh -m work         # Full development stack
./setup.sh -m macmini      # Desktop setup

# Skip system updates or Homebrew
./setup.sh -s --skip-homebrew

# See all options
./setup.sh --help
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

- **Modular Architecture**: 74+ individual application modules organized into 14 functional categories
- **Fine-Grained Control**: Enable/disable individual applications independently
- **Reliable Nix Installation**: Uses Determinate Systems installer with flakes enabled by default
- **Machine-Specific Configurations**: Easy switching between different setups
- **Conditional Dependencies**: Apps only install when their dependencies (like Homebrew) are enabled
- **Home Manager Integration**: User environment management alongside system configuration
- **Automated Setup**: One-command installation with progress tracking and error handling

## Module Categories

Applications and tools are organized by function for intuitive management:

- **AI**: claude, chatgpt, perplexity, poe
- **Browsers**: chrome, firefox, arc, microsoft-edge
- **Communication**: slack, discord, zoom, telegram, deepl
- **Design**: figma, blender, miro
- **Development**: docker, git, postman, xcode, aws, kubernetes, and 40+ CLI tools
- **Editors**: vim, emacs, neovim, vscode, cursor, typora
- **Languages**: python, nodejs, rust, go, and more
- **Media**: spotify, kindle
- **Productivity**: notion, obsidian, things3, amphetamine, and more
- **Security**: 1password, wireguard
- **System**: homebrew, aerospace, fonts
- **Terminal**: zsh, starship, wezterm
- **Utilities**: raycast, karabiner-elements, flux, and more

## Example Configuration

```nix
# Machine-specific module configuration
modules = {
  # Foundation
  system.homebrew.enable = true;
  
  # Development
  development.docker.enable = true;
  development.git.enable = true;
  editors.cursor.enable = true;
  languages.python.enable = true;
  
  # Applications
  browsers.chrome.enable = true;
  communication.slack.enable = true;
  productivity.notion.enable = true;
  
  # Security & Utilities
  security."1password".enable = true;
  utilities.raycast.enable = true;
};
```

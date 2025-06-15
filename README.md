* Dotfiles

Nix Darwin configuration with Home Manager for macOS system and user environment management.

** Quick Install

#+BEGIN_SRC bash
git clone https://github.com/nobv/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
#+END_SRC

** Custom Installation

#+BEGIN_SRC bash
# Install with specific machine configuration
./install.sh -m macbook      # Development-focused setup
./install.sh -m work         # Full development stack
./install.sh -m macmini      # Desktop setup

# Skip system updates or Homebrew
./install.sh -s --skip-homebrew

# See all options
./install.sh --help
#+END_SRC

** Available Machine Configurations

- =default= - Basic configuration with minimal modules
- =macbook= - Development-focused (tmux, docker, python, kubernetes)
- =macmini= - Desktop setup (emacs, lighter dev tools, visible dock)
- =work= - Full development stack (all languages and tools)

** Switching Configurations

#+BEGIN_SRC bash
darwin-rebuild switch --flake ~/.dotfiles#<machine>
#+END_SRC

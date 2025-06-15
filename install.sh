#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is only for macOS"
    exit 1
fi

# Parse command line arguments
MACHINE=""
SKIP_SYSTEM_UPDATE=false
SKIP_HOMEBREW=false

show_help() {
    cat << EOF
Usage: $0 -m MACHINE [OPTIONS]

Install nobv's dotfiles with Nix Darwin and Home Manager

OPTIONS:
    -m, --machine MACHINE    Machine configuration to use (required)
                            Available: macbook, macmini, work
    -s, --skip-system       Skip macOS system updates
    --skip-homebrew         Skip Homebrew installation
    -h, --help              Show this help message

EXAMPLES:
    $0 -m macbook          Install MacBook configuration
    $0 -m work --skip-system   Install work config, skip system updates
    $0 -m macmini --skip-homebrew   Install Mac Mini config, skip Homebrew

EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--machine)
            MACHINE="$2"
            shift 2
            ;;
        -s|--skip-system)
            SKIP_SYSTEM_UPDATE=true
            shift
            ;;
        --skip-homebrew)
            SKIP_HOMEBREW=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate machine configuration is provided
if [[ -z "$MACHINE" ]]; then
    log_error "Machine configuration is required"
    log_info "Use -m option to specify machine configuration"
    show_help
    exit 1
fi

# Validate machine configuration
if [[ ! "$MACHINE" =~ ^(macbook|macmini|work)$ ]]; then
    log_error "Invalid machine configuration: $MACHINE"
    log_info "Available configurations: macbook, macmini, work"
    exit 1
fi

log_info "Starting installation with machine configuration: $MACHINE"

# Step 1: System Updates
if [[ "$SKIP_SYSTEM_UPDATE" == false ]]; then
    log_info "Updating macOS and installing Xcode Command Line Tools..."
    sudo softwareupdate --install --all --install-rosetta --agree-to-license || log_warning "Some system updates may have failed"
    xcode-select --install 2>/dev/null || log_info "Xcode Command Line Tools already installed"
    log_success "System updates completed"
else
    log_info "Skipping system updates"
fi

# Step 2: Install Nix using Determinate Systems installer
if ! command -v nix &> /dev/null; then
    log_info "Installing Nix package manager using Determinate Systems installer..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
    log_success "Nix installed successfully"
    
    # Source Nix environment
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
else
    log_info "Nix already installed"
fi

# Step 3: Enable Nix flakes and check installation
log_info "Checking Nix installation..."
nix --version || {
    log_error "Nix installation failed"
    exit 1
}

# Step 4: Install Homebrew (if not skipped)
if [[ "$SKIP_HOMEBREW" == false ]]; then
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log_success "Homebrew installed successfully"
    else
        log_info "Homebrew already installed"
    fi
else
    log_info "Skipping Homebrew installation"
fi

# Step 5: Clone dotfiles repository (if not already present)
DOTFILES_DIR="$HOME/.dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
    log_info "Cloning dotfiles repository..."
    git clone https://github.com/nobv/dotfiles.git "$DOTFILES_DIR"
    log_success "Dotfiles repository cloned"
else
    log_info "Dotfiles repository already exists"
    cd "$DOTFILES_DIR"
    git pull origin master || log_warning "Failed to update dotfiles repository"
fi

cd "$DOTFILES_DIR"

# Step 6: Fix /run directory issue (common on macOS)
if [[ ! -d /run ]]; then
    log_info "Creating /run directory symlink..."
    printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
    if [[ -f /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util ]]; then
        /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
    fi
    log_success "/run directory configured"
fi

# Step 7: Build and apply Nix Darwin configuration
log_info "Building Nix Darwin configuration for machine: $MACHINE"
nix build ".#darwinConfigurations.$MACHINE.system" --extra-experimental-features "nix-command flakes"

log_info "Applying Nix Darwin configuration..."
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$MACHINE"

log_success "Nix Darwin configuration applied successfully!"

# Step 8: Final instructions
echo ""
log_success "Installation completed successfully!"
echo ""
log_info "Next steps:"
echo "  1. Restart your terminal or run: exec \$SHELL -l"
echo "  2. Configure any remaining manual settings"
echo "  3. Log into App Store for MAS apps (if using homebrew module)"
echo ""
log_info "To switch machine configurations later:"
echo "  darwin-rebuild switch --flake ~/.dotfiles#<machine>"
echo ""
log_info "Available machine configurations:"
echo "  - macbook: Development-focused (tmux, docker, python)"
echo "  - macmini: Desktop setup (emacs, lighter tools)"
echo "  - work: Full development stack"
echo ""
log_info "For more information, see ~/.dotfiles/CLAUDE.md"

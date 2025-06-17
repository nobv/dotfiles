#!/bin/bash

set -e  # Exit on any error

# Source shared utilities
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/scripts/lib.sh"

# Check if we're on macOS
check_macos

# Parse command line arguments
MACHINE=""
SKIP_HOMEBREW=false

show_help() {
    cat << EOF
Usage: $0 -m MACHINE [OPTIONS]

Install nobv's dotfiles with Nix Darwin and Home Manager

OPTIONS:
    -m, --machine MACHINE    Machine configuration to use (required)
                            Available: macbook, macmini, work
    --skip-homebrew         Skip Homebrew installation
    -h, --help              Show this help message

EXAMPLES:
    $0 -m macbook          Install MacBook configuration
    $0 -m work             Install work configuration
    $0 -m macmini --skip-homebrew   Install Mac Mini config, skip Homebrew

EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--machine)
            MACHINE="$2"
            shift 2
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

# Step 1: Install Nix using Determinate Systems installer
if ! command -v nix &> /dev/null; then
    log_info "Installing Nix package manager using Determinate Systems installer..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    # chose no
    log_success "Nix installed successfully"
    
    # Source Nix environment
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
else
    log_info "Nix already installed"
fi

# Step 2: Enable Nix flakes and check installation
log_info "Checking Nix installation..."
nix --version || {
    log_error "Nix installation failed"
    exit 1
}

# Step 3: Install Homebrew (if not skipped)
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

# Step 4: Clone dotfiles repository (if not already present)
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

# Step 5: Generate machine-specific config.nix if needed
config_file="machines/$MACHINE/config.nix"
if [[ ! -f "$config_file" ]]; then
    log_info "Generating machine-specific config.nix for $MACHINE..."
    
    # Copy template and prompt for username
    if [[ -f "templates/machine-config.nix.template" ]]; then
        cp "templates/machine-config.nix.template" "$config_file"
        
        # Get current username as default
        current_user=$(whoami)
        
        # Prompt for username
        echo ""
        log_info "Please configure your machine-specific settings:"
        read -p "Enter your username (default: $current_user): " user_input
        username="${user_input:-$current_user}"
        
        # Replace template placeholder
        sed -i.bak "s/REPLACE_WITH_YOUR_USERNAME/$username/g" "$config_file"
        rm "$config_file.bak"
        
        log_success "Created $config_file with username: $username"
        log_info "You can edit $config_file later to add more machine-specific settings"
    else
        log_error "Template file not found: templates/machine-config.nix.template"
        log_info "Please create $config_file manually with: { username = \"$current_user\"; }"
        exit 1
    fi
else
    log_info "Machine config already exists: $config_file"
fi

## Step 6: Fix /run directory issue (common on macOS)
#if [[ ! -d /run ]]; then
#    log_info "Creating /run directory symlink..."
#    printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
#    if [[ -f /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util ]]; then
#        /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
#    fi
#    log_success "/run directory configured"
#fi

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
echo "  1. Restart your terminal or run: reload"
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

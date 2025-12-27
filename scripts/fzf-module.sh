#!/bin/bash

# Interactive module search and enablement using fzf
# This script allows users to search for modules and enable/disable them using fzf

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Colors for status display
ENABLED_COLOR='\033[0;32m'   # Green
DISABLED_COLOR='\033[0;31m'  # Red
AVAILABLE_COLOR='\033[0;33m' # Yellow
BOLD='\033[1m'
NC='\033[0m' # No Color

# Status symbols
ENABLED_SYMBOL="✅"
DISABLED_SYMBOL="❌"
AVAILABLE_SYMBOL="🆕"

# Global variables
AVAILABLE_MODULES=()
CATEGORIES=()
MACHINE=""

# Show usage
show_usage() {
    echo "Usage: $0 [options] [machine-name]"
    echo
    echo "Interactive module search and enablement using fzf"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -m, --machine       Specify machine name"
    echo
    echo "Examples:"
    echo "  $0                  # Interactive mode for current machine"
    echo "  $0 work             # Interactive mode for work machine"
    echo
}

# Check if fzf is installed
check_fzf() {
    if ! command -v fzf >/dev/null 2>&1; then
        log_error "fzf is not installed. Please install it first."
        echo "You can install fzf using:"
        echo "  brew install fzf  # on macOS with Homebrew"
        echo "  nix-env -iA nixpkgs.fzf  # with Nix"
        exit 1
    fi
}

# Detect current machine
detect_current_machine() {
    local hostname=$(hostname -s)
    
    # Check if there's a machine config that matches hostname
    for machine_dir in "$DOTFILES_DIR/machines"/*; do
        if [[ -d "$machine_dir" && "$(basename "$machine_dir")" == "$hostname" ]]; then
            echo "$(basename "$machine_dir")"
            return 0
        fi
    done
    
    # Fallback to the first available machine
    for machine_dir in "$DOTFILES_DIR/machines"/*; do
        if [[ -d "$machine_dir" && -f "$machine_dir/default.nix" ]]; then
            echo "$(basename "$machine_dir")"
            return 0
        fi
    done
    
    return 1
}

# Get available machines
get_available_machines() {
    local machines=()
    for machine_dir in "$DOTFILES_DIR/machines"/*; do
        if [[ -d "$machine_dir" && -f "$machine_dir/default.nix" ]]; then
            machines+=("$(basename "$machine_dir")")
        fi
    done
    printf '%s\n' "${machines[@]}"
}

# Discover all available modules
discover_modules() {
    log_info "Discovering available modules..."
    
    AVAILABLE_MODULES=()
    CATEGORIES=()
    
    for category_dir in "$DOTFILES_DIR/modules"/*; do
        if [[ -d "$category_dir" ]]; then
            local category=$(basename "$category_dir")
            CATEGORIES+=("$category")
            
            for module_dir in "$category_dir"/*; do
                if [[ -d "$module_dir" && -f "$module_dir/default.nix" ]]; then
                    local module_name=$(basename "$module_dir")
                    local module_key="$category.$module_name"
                    AVAILABLE_MODULES+=("$module_key")
                fi
            done
        fi
    done
    
    log_success "Discovered ${#AVAILABLE_MODULES[@]} modules in ${#CATEGORIES[@]} categories"
}

# Extract module description from default.nix
extract_module_description() {
    local module_file="$1"
    local module_name="$2"
    
    # Try to extract description from mkEnableOption
    local description
    description=$(grep -o 'mkEnableOption "[^"]*"' "$module_file" 2>/dev/null | sed 's/mkEnableOption "//' | sed 's/"//' | head -n 1)
    
    if [ -n "$description" ]; then
        echo "$description"
    else
        echo "$module_name application"
    fi
}

# Get module status from configuration
get_module_status() {
    local machine="$1"
    local module_key="$2"
    local config_file="$DOTFILES_DIR/machines/$machine/default.nix"
    
    local category="${module_key%.*}"
    local module_name="${module_key#*.}"
    
    # Remove quotes from module name if present
    module_name=$(echo "$module_name" | sed 's/"//g')
    
    # Look for the module in the config file
    if grep -q "^[[:space:]]*$module_name\.enable[[:space:]]*=[[:space:]]*true" "$config_file"; then
        echo "enabled"
    elif grep -q "^[[:space:]]*$module_name\.enable[[:space:]]*=[[:space:]]*false" "$config_file"; then
        echo "disabled"
    else
        echo "available"
    fi
}

# Get module description by key
get_module_description() {
    local module_key="$1"
    local category="${module_key%.*}"
    local module_name="${module_key#*.}"
    local module_file="$DOTFILES_DIR/modules/$category/$module_name/default.nix"
    
    extract_module_description "$module_file" "$module_name"
}

# Format module for fzf display
format_module_for_fzf() {
    local machine="$1"
    local module_key="$2"
    local category="${module_key%.*}"
    local module_name="${module_key#*.}"
    local status=$(get_module_status "$machine" "$module_key")
    local description=$(get_module_description "$module_key")
    
    # Format: [STATUS] category.module_name - Description
    case "$status" in
        "enabled")
            echo -e "$ENABLED_SYMBOL ${ENABLED_COLOR}[ENABLED]${NC}  $category.$module_name - $description"
            ;;
        "disabled")
            echo -e "$DISABLED_SYMBOL ${DISABLED_COLOR}[DISABLED]${NC} $category.$module_name - $description"
            ;;
        "available")
            echo -e "$AVAILABLE_SYMBOL ${AVAILABLE_COLOR}[AVAILABLE]${NC} $category.$module_name - $description"
            ;;
    esac
}

# Toggle module enable status
toggle_module() {
    local machine="$1"
    local module_key="$2"
    local current_status=$(get_module_status "$machine" "$module_key")
    local new_status
    
    case "$current_status" in
        "enabled")
            new_status="false"
            ;;
        "disabled"|"available")
            new_status="true"
            ;;
    esac
    
    # Apply changes to configuration file
    apply_module_change "$machine" "$module_key" "$new_status"
}

# Apply module change to configuration file
apply_module_change() {
    local machine="$1"
    local module_key="$2"
    local new_status="$3"
    local config_file="$DOTFILES_DIR/machines/$machine/default.nix"
    
    # Create backup
    cp "$config_file" "$config_file.backup"
    
    local category="${module_key%.*}"
    local module="${module_key#*.}"
    local enable_line="      $module.enable = $new_status;"
    
    # Check if module already exists in config
    if grep -q "^[[:space:]]*$module\.enable[[:space:]]*=" "$config_file"; then
        # Update existing line
        sed -i.tmp "s/^[[:space:]]*$module\.enable[[:space:]]*=.*$/      $module.enable = $new_status;/" "$config_file"
        rm -f "$config_file.tmp"
    else
        # Add new module to the appropriate category
        if grep -q "^[[:space:]]*$category[[:space:]]*=" "$config_file"; then
            # Category section exists, add module to it
            # Find the last line in the category section and add the module before the closing brace
            local category_start_line=$(grep -n "^[[:space:]]*$category[[:space:]]*=" "$config_file" | cut -d: -f1)
            local category_end_line=$(awk -v start="$category_start_line" '
                NR >= start && /^[[:space:]]*};/ { print NR; exit }
            ' "$config_file")
            
            if [ -n "$category_start_line" ] && [ -n "$category_end_line" ]; then
                # Insert the new line before the closing brace
                sed -i.tmp "${category_end_line}i\\
$enable_line" "$config_file"
                if [ -f "$config_file.tmp" ]; then
                    rm -f "$config_file.tmp"
                fi
            else
                log_error "Could not find category boundaries for $category"
                return 1
            fi
        else
            # Category doesn't exist, create it
            # Find the modules = { line and add the new category after it
            sed -i.tmp "/^[[:space:]]*modules[[:space:]]*=[[:space:]]*{/a\\
\\
    $category = {\\
$enable_line\\
    };" "$config_file"
            rm -f "$config_file.tmp"
        fi
    fi
    
    # Validate the file
    if [ -f "$config_file" ] && validate_nix_file "$config_file"; then
        rm -f "$config_file.backup"
        log_success "Configuration file updated successfully"
        return 0
    else
        # Show the problematic content before restoring backup
        log_error "Configuration validation failed"
        log_info "Showing problematic content:"
        cat "$config_file" >&2
        log_error "Restoring backup"
        mv "$config_file.backup" "$config_file"
        return 1
    fi
}

# Validate nix file syntax
validate_nix_file() {
    local file="$1"
    
    if command -v nix-instantiate >/dev/null 2>&1; then
        local nix_error
        nix_error=$(nix-instantiate --parse "$file" 2>&1)
        if [ $? -eq 0 ]; then
            return 0
        else
            log_error "Nix syntax validation failed:"
            echo "$nix_error" >&2
            return 1
        fi
    else
        # Basic syntax check - check for balanced braces and basic structure
        if [ -f "$file" ] && grep -q "modules.*=" "$file"; then
            # Count braces to ensure they're balanced
            local open_braces=$(grep -o '{' "$file" | wc -l)
            local close_braces=$(grep -o '}' "$file" | wc -l)
            if [ "$open_braces" -eq "$close_braces" ]; then
                return 0
            else
                log_error "Unbalanced braces detected (open: $open_braces, close: $close_braces)"
                return 1
            fi
        else
            log_error "File validation failed - file not found or invalid structure"
            return 1
        fi
    fi
}

# Generate list of modules for fzf
generate_module_list() {
    local machine="$1"
    local module_list=()
    
    for module_key in "${AVAILABLE_MODULES[@]}"; do
        module_list+=("$(format_module_for_fzf "$machine" "$module_key")")
    done
    
    printf '%s\n' "${module_list[@]}"
}

# Extract module key from formatted line
extract_module_key() {
    local line="$1"
    # Extract the part between status and description
    echo "$line" | sed -E 's/^.*\[(ENABLED|DISABLED|AVAILABLE)\][[:space:]]+([^[:space:]]+)[[:space:]]+-.*/\2/'
}

# Interactive module search and toggle using fzf
interactive_module_search() {
    local machine="$1"
    local header="Search and select modules to toggle (ESC to exit, TAB to select multiple)"
    
    # Generate module list
    local module_list=$(generate_module_list "$machine")
    
    # Use fzf for interactive selection
    local selected_modules
    selected_modules=$(echo "$module_list" | fzf --ansi --multi --header="$header" \
        --preview="echo 'Machine: $machine\n\nSelected module will be toggled (enabled ↔ disabled)'" \
        --preview-window=up:3:wrap)
    
    # Process selected modules
    if [ -n "$selected_modules" ]; then
        echo "$selected_modules" | while read -r line; do
            local module_key=$(extract_module_key "$line")
            if [ -n "$module_key" ]; then
                echo -n "Toggling $module_key... "
                if toggle_module "$machine" "$module_key"; then
                    echo -e "${GREEN}success${NC}"
                else
                    echo -e "${RED}failed${NC}"
                fi
            fi
        done
        
        # Ask if user wants to rebuild
        echo
        echo -n "Do you want to rebuild the configuration now? (y/N): "
        read -r rebuild
        case "$rebuild" in
            [Yy]|[Yy][Ee][Ss])
                echo "Running: darwin-rebuild switch --flake .#$machine"
                darwin-rebuild switch --flake ".#$machine"
                ;;
            *)
                echo "Configuration updated. Run the following command to apply changes:"
                echo "  darwin-rebuild switch --flake .#$machine"
                ;;
        esac
    fi
}

# Main function
main() {
    local machine=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -m|--machine)
                machine="$2"
                shift 2
                ;;
            *)
                if [[ -z "$machine" ]]; then
                    machine="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Check if fzf is installed
    check_fzf
    
    # Check if we're in the dotfiles directory
    if [ ! -f "$DOTFILES_DIR/flake.nix" ]; then
        log_error "Not in dotfiles directory. Please run from $DOTFILES_DIR"
        exit 1
    fi
    
    # Discover modules
    discover_modules
    
    # Determine machine
    if [ -z "$machine" ]; then
        machine=$(detect_current_machine)
        if [ -z "$machine" ]; then
            log_error "Could not detect current machine"
            echo "Available machines:"
            get_available_machines
            exit 1
        fi
        log_info "Auto-detected machine: $machine"
    fi
    
    # Validate machine
    if [ ! -d "$DOTFILES_DIR/machines/$machine" ]; then
        log_error "Machine configuration not found: $machine"
        echo "Available machines:"
        get_available_machines
        exit 1
    fi
    
    # Start interactive search
    interactive_module_search "$machine"
}

# Run main function with all arguments
main "$@"
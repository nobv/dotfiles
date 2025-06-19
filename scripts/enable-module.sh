#!/bin/bash

# Interactive module enable/disable script for dotfiles configuration
# This script dynamically discovers modules and manages their enable state

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Global variables (using different approach for associative arrays)
AVAILABLE_MODULES=()
CATEGORIES=()

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

# Show usage
show_usage() {
    echo "Usage: $0 [options] [machine-name]"
    echo
    echo "Interactive module management for dotfiles configuration"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -l, --list          List all available modules and their status"
    echo "  -m, --machine       Specify machine name"
    echo
    echo "Examples:"
    echo "  $0                  # Interactive mode for current machine"
    echo "  $0 work             # Interactive mode for work machine"
    echo "  $0 --list           # List all modules and their status"
    echo
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
                    
                    # Module will be added to AVAILABLE_MODULES array
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

# Parse machine configuration to get current module status
parse_machine_config() {
    local machine="$1"
    local config_file="$DOTFILES_DIR/machines/$machine/default.nix"
    
    if [ ! -f "$config_file" ]; then
        log_error "Machine configuration not found: $config_file"
        return 1
    fi
    
    log_info "Parsing configuration for machine: $machine"
}

# Display modules by category with status
display_modules() {
    local machine="$1"
    
    echo
    echo "========================================="
    echo "Module Status for Machine: $machine"
    echo "========================================="
    echo
    
    for category in "${CATEGORIES[@]}"; do
        local has_modules=false
        
        # Check if category has any modules
        for module_key in "${AVAILABLE_MODULES[@]}"; do
            if [ "${module_key#$category.}" != "$module_key" ]; then
                has_modules=true
                break
            fi
        done
        
        if [ "$has_modules" = "true" ]; then
            echo -e "${BOLD}=== $(echo "$category" | tr '[:lower:]' '[:upper:]') ===${NC}"
            
            for module_key in "${AVAILABLE_MODULES[@]}"; do
                if [ "${module_key#$category.}" != "$module_key" ]; then
                    local module_name="${module_key#$category.}"
                    local status=$(get_module_status "$machine" "$module_key")
                    local description=$(get_module_description "$module_key")
                    
                    case "$status" in
                        "enabled")
                            echo -e "  $ENABLED_SYMBOL ${ENABLED_COLOR}[ENABLED]${NC}   $module_name - $description"
                            ;;
                        "disabled")
                            echo -e "  $DISABLED_SYMBOL ${DISABLED_COLOR}[DISABLED]${NC}  $module_name - $description"
                            ;;
                        "available")
                            echo -e "  $AVAILABLE_SYMBOL ${AVAILABLE_COLOR}[AVAILABLE]${NC} $module_name - $description"
                            ;;
                    esac
                fi
            done
            echo
        fi
    done
}

# Interactive module selection
interactive_selection() {
    local machine="$1"
    
    echo "Select a category to manage:"
    echo
    
    local i=1
    for category in "${CATEGORIES[@]}"; do
        local module_count=0
        local enabled_count=0
        
        for module_key in "${AVAILABLE_MODULES[@]}"; do
            if [ "${module_key#$category.}" != "$module_key" ]; then
                module_count=$((module_count + 1))
                local status=$(get_module_status "$machine" "$module_key")
                if [ "$status" = "enabled" ]; then
                    enabled_count=$((enabled_count + 1))
                fi
            fi
        done
        
        echo "  $i) $category ($enabled_count/$module_count enabled)"
        i=$((i + 1))
    done
    
    echo "  0) Exit"
    echo
    echo -n "Select category (0-${#CATEGORIES[@]}): "
    read -r selection
    
    if [ "$selection" = "0" ]; then
        log_info "Exiting..."
        exit 0
    fi
    
    if [ "$selection" -ge 1 ] && [ "$selection" -le "${#CATEGORIES[@]}" ] 2>/dev/null; then
        local selected_category="${CATEGORIES[$((selection-1))]}"
        manage_category_modules "$machine" "$selected_category"
    else
        log_error "Invalid selection"
        interactive_selection "$machine"
    fi
}

# Manage modules in a specific category
manage_category_modules() {
    local machine="$1"
    local category="$2"
    
    echo
    echo "=== Managing $category modules ==="
    echo
    
    local category_modules=()
    for module_key in "${AVAILABLE_MODULES[@]}"; do
        if [ "${module_key#$category.}" != "$module_key" ]; then
            category_modules+=("$module_key")
        fi
    done
    
    if [ ${#category_modules[@]} -eq 0 ]; then
        log_warning "No modules found in category: $category"
        return
    fi
    
    # Display current status
    for module_key in "${category_modules[@]}"; do
        local module_name="${module_key#$category.}"
        local status=$(get_module_status "$machine" "$module_key")
        local description=$(get_module_description "$module_key")
        
        case "$status" in
            "enabled")
                echo -e "$ENABLED_SYMBOL ${ENABLED_COLOR}[ENABLED]${NC}   $module_name - $description"
                ;;
            "disabled")
                echo -e "$DISABLED_SYMBOL ${DISABLED_COLOR}[DISABLED]${NC}  $module_name - $description"
                ;;
            "available")
                echo -e "$AVAILABLE_SYMBOL ${AVAILABLE_COLOR}[AVAILABLE]${NC} $module_name - $description"
                ;;
        esac
    done
    
    echo
    echo "Enter module name to toggle (or 'back' to return, 'list' to see status again):"
    read -r input
    
    case "$input" in
        "back")
            interactive_selection "$machine"
            ;;
        "list")
            manage_category_modules "$machine" "$category"
            ;;
        *)
            local target_module="$category.$input"
            if [[ " ${category_modules[*]} " =~ " $target_module " ]]; then
                toggle_module "$machine" "$target_module"
                manage_category_modules "$machine" "$category"
            else
                log_error "Module not found: $input"
                manage_category_modules "$machine" "$category"
            fi
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
    
    log_info "Toggling $module_key: $current_status -> $new_status"
    
    # Apply changes to configuration file
    if apply_module_change "$machine" "$module_key" "$new_status"; then
        log_success "Successfully updated $module_key"
    else
        log_error "Failed to update $module_key"
    fi
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
    
    log_info "Enable line: $enable_line"
    
    log_info "Updating $module_key to $new_status in $category category"
    
    # Check if module already exists in config
    if grep -q "^[[:space:]]*$module\.enable[[:space:]]*=" "$config_file"; then
        # Update existing line
        log_info "Updating existing module line"
        sed -i.tmp "s/^[[:space:]]*$module\.enable[[:space:]]*=.*$/      $module.enable = $new_status;/" "$config_file"
        rm -f "$config_file.tmp"
    else
        # Add new module to the appropriate category
        if grep -q "^[[:space:]]*$category[[:space:]]*=" "$config_file"; then
            # Category section exists, add module to it
            log_info "Adding module to existing $category category"
            
            # Find the last line in the category section and add the module before the closing brace
            # Look for the pattern: category = { ... };
            local category_start_line=$(grep -n "^[[:space:]]*$category[[:space:]]*=" "$config_file" | cut -d: -f1)
            local category_end_line=$(awk -v start="$category_start_line" '
                NR >= start && /^[[:space:]]*};/ { print NR; exit }
            ' "$config_file")
            
            if [ -n "$category_start_line" ] && [ -n "$category_end_line" ]; then
                log_info "Found category boundaries: start=$category_start_line, end=$category_end_line"
                # Insert the new line before the closing brace
                sed -i.tmp "${category_end_line}i\\
$enable_line" "$config_file"
                if [ -f "$config_file.tmp" ]; then
                    rm -f "$config_file.tmp"
                fi
                log_info "Configuration file modified"
            else
                log_error "Could not find category boundaries (start=$category_start_line, end=$category_end_line)"
                return 1
            fi
        else
            # Category doesn't exist, create it
            log_info "Creating new $category category"
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

# Main function
main() {
    local machine=""
    local list_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_only=true
                shift
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
    
    # Parse current configuration
    parse_machine_config "$machine"
    
    if [ "$list_only" = "true" ]; then
        display_modules "$machine"
        exit 0
    fi
    
    # Start interactive session
    while true; do
        display_modules "$machine"
        interactive_selection "$machine"
    done
}

# Run main function with all arguments
main "$@"
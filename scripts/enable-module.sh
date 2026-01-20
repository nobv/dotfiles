#!/bin/bash

# Interactive module enable/disable script for dotfiles configuration
# This script dynamically discovers modules and manages their enable state

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Global variables (using different approach for associative arrays)
AVAILABLE_MODULES=()
CATEGORIES=()
SELECTED_MODULES=()
MODULES_PER_PAGE=15

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

# Check if module is selected for toggle
is_module_selected() {
    local module_key="$1"
    for selected in "${SELECTED_MODULES[@]}"; do
        if [ "$selected" = "$module_key" ]; then
            return 0
        fi
    done
    return 1
}

# Toggle module selection
toggle_module_selection() {
    local module_key="$1"
    local new_selected=()
    local found=false
    
    for selected in "${SELECTED_MODULES[@]}"; do
        if [ "$selected" = "$module_key" ]; then
            found=true
        else
            new_selected+=("$selected")
        fi
    done
    
    if [ "$found" = "false" ]; then
        new_selected+=("$module_key")
    fi
    
    SELECTED_MODULES=("${new_selected[@]}")
}

# Clear all selections
clear_selections() {
    SELECTED_MODULES=()
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

# Interactive module selector with multiple selection
interactive_module_selector() {
    local machine="$1"
    local category="$2"
    local page="${3:-1}"
    
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
    
    local total_pages=$(( (${#category_modules[@]} + MODULES_PER_PAGE - 1) / MODULES_PER_PAGE ))
    local start_idx=$(( (page - 1) * MODULES_PER_PAGE ))
    local end_idx=$(( start_idx + MODULES_PER_PAGE ))
    
    # Clear screen for better UX
    clear
    
    echo "========================================="
    echo "Managing $category modules (Page $page/$total_pages)"
    echo "========================================="
    echo
    
    # Display modules for current page
    local current_idx=0
    for module_key in "${category_modules[@]}"; do
        if [ $current_idx -ge $start_idx ] && [ $current_idx -lt $end_idx ]; then
            local module_name="${module_key#$category.}"
            local status=$(get_module_status "$machine" "$module_key")
            local description=$(get_module_description "$module_key")
            local item_num=$((current_idx + 1))
            
            # Selection checkbox
            local checkbox="[ ]"
            if is_module_selected "$module_key"; then
                checkbox="[x]"
            fi
            
            # Status display
            case "$status" in
                "enabled")
                    echo -e "$checkbox $item_num) $ENABLED_SYMBOL ${ENABLED_COLOR}[ENABLED]${NC}   $module_name"
                    ;;
                "disabled")  
                    echo -e "$checkbox $item_num) $DISABLED_SYMBOL ${DISABLED_COLOR}[DISABLED]${NC}  $module_name"
                    ;;
                "available")
                    echo -e "$checkbox $item_num) $AVAILABLE_SYMBOL ${AVAILABLE_COLOR}[AVAILABLE]${NC} $module_name"
                    ;;
            esac
            echo "    $description"
            echo
        fi
        current_idx=$((current_idx + 1))
    done
    
    # Show selection summary
    local to_enable=0
    local to_disable=0
    for selected in "${SELECTED_MODULES[@]}"; do
        if [ "${selected#$category.}" != "$selected" ]; then
            local current_status=$(get_module_status "$machine" "$selected")
            if [ "$current_status" = "enabled" ]; then
                to_disable=$((to_disable + 1))
            else
                to_enable=$((to_enable + 1))
            fi
        fi
    done
    
    echo "========================================="
    echo "Selected: $to_enable to enable, $to_disable to disable"
    echo
    echo "Navigation:"
    echo "  [1-$((end_idx > ${#category_modules[@]} ? ${#category_modules[@]} - start_idx : MODULES_PER_PAGE))] Select item  [Space] Apply to current page"
    echo "  [Enter] Apply changes    [c] Clear selections"
    if [ $page -gt 1 ]; then
        echo "  [p] Previous page"
    fi
    if [ $page -lt $total_pages ]; then
        echo "  [n] Next page"
    fi
    echo "  [q] Back to categories"
    echo
    echo -n "Choice: "
    
    read -r choice
    
    case "$choice" in
        "q")
            clear_selections
            interactive_selection "$machine"
            ;;
        "c")
            clear_selections
            interactive_module_selector "$machine" "$category" "$page"
            ;;
        "n")
            if [ $page -lt $total_pages ]; then
                interactive_module_selector "$machine" "$category" $((page + 1))
            else
                interactive_module_selector "$machine" "$category" "$page"
            fi
            ;;
        "p")
            if [ $page -gt 1 ]; then
                interactive_module_selector "$machine" "$category" $((page - 1))
            else
                interactive_module_selector "$machine" "$category" "$page"
            fi
            ;;
        "")
            # Enter pressed - apply changes
            if [ ${#SELECTED_MODULES[@]} -gt 0 ]; then
                apply_bulk_changes "$machine" "$category"
            else
                log_warning "No modules selected"
                sleep 1
                interactive_module_selector "$machine" "$category" "$page"
            fi
            ;;
        " ")
            # Space key - toggle all visible modules on current page
            for module_key in "${category_modules[@]}"; do
                local idx=0
                for mod in "${category_modules[@]}"; do
                    if [ "$mod" = "$module_key" ]; then
                        break
                    fi
                    idx=$((idx + 1))
                done
                if [ $idx -ge $start_idx ] && [ $idx -lt $end_idx ]; then
                    toggle_module_selection "$module_key"
                fi
            done
            interactive_module_selector "$machine" "$category" "$page"
            ;;
        *)
            # Check if it's a number for item selection
            if [ "$choice" -ge 1 ] && [ "$choice" -le $((end_idx - start_idx)) ] 2>/dev/null; then
                local target_idx=$((start_idx + choice - 1))
                if [ $target_idx -lt ${#category_modules[@]} ]; then
                    local target_module="${category_modules[$target_idx]}"
                    toggle_module_selection "$target_module"
                fi
                interactive_module_selector "$machine" "$category" "$page"
            else
                log_error "Invalid choice: $choice"
                sleep 1
                interactive_module_selector "$machine" "$category" "$page"
            fi
            ;;
    esac
}

# Apply bulk changes to selected modules
apply_bulk_changes() {
    local machine="$1"
    local category="$2"
    
    if [ ${#SELECTED_MODULES[@]} -eq 0 ]; then
        log_warning "No modules selected"
        return
    fi
    
    clear
    echo "========================================="
    echo "Applying Changes"
    echo "========================================="
    echo
    
    local success_count=0
    local total_count=0
    
    for module_key in "${SELECTED_MODULES[@]}"; do
        if [ "${module_key#$category.}" != "$module_key" ]; then
            total_count=$((total_count + 1))
            local current_status=$(get_module_status "$machine" "$module_key")
            local module_name="${module_key#$category.}"
            
            echo -n "Processing $module_name... "
            
            if toggle_module "$machine" "$module_key"; then
                echo -e "\033[0;32m✓\033[0m"
                success_count=$((success_count + 1))
            else
                echo -e "\033[0;31m✗\033[0m"
            fi
        fi
    done
    
    echo
    echo "========================================="
    echo "Results: $success_count/$total_count successful"
    echo "========================================="
    echo
    
    clear_selections
    
    echo "Press Enter to continue..."
    read -r
    interactive_selection "$machine"
}

# Legacy function - redirect to new interface
manage_category_modules() {
    local machine="$1"
    local category="$2"
    interactive_module_selector "$machine" "$category" 1
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
    
    # Apply changes to configuration file (return success/failure)
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
    
    # Silent mode for bulk operations - only log errors
    
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
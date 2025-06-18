#!/bin/bash

# Add new module to dotfiles configuration
# This script helps categorize and create new modules with proper structure

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Available categories
declare -a CATEGORIES=(
    "ai"
    "browsers"
    "communication"
    "design"
    "development"
    "editors"
    "languages"
    "media"
    "productivity"
    "security"
    "system"
    "terminal"
    "utilities"
)

# Category descriptions for user guidance
get_category_desc() {
    case "$1" in
        "ai") echo "AI applications and tools" ;;
        "browsers") echo "Web browsers" ;;
        "communication") echo "Communication and messaging apps" ;;
        "design") echo "Design and creative tools" ;;
        "development") echo "Development tools and CLI utilities" ;;
        "editors") echo "Text editors and IDEs" ;;
        "languages") echo "Programming language environments" ;;
        "media") echo "Media and entertainment apps" ;;
        "productivity") echo "Productivity tools, launchers, note-taking" ;;
        "security") echo "Security and privacy tools" ;;
        "system") echo "System-level configurations and foundational tools" ;;
        "terminal") echo "Terminal and shell configurations" ;;
        "utilities") echo "System utilities and helper tools" ;;
        *) echo "Unknown category" ;;
    esac
}

# Show usage
show_usage() {
    echo "Usage: $0 [app-name]"
    echo
    echo "Interactive module creation for dotfiles configuration"
    echo
    echo "Examples:"
    echo "  $0 alfred"
    echo "  $0 # Interactive mode"
    echo
    echo "Available categories:"
    for category in "${CATEGORIES[@]}"; do
        echo "  $category - $(get_category_desc "$category")"
    done
}

# Get app name from user
get_app_name() {
    if [[ -n "$1" ]]; then
        echo "$1"
    else
        echo -n "Enter app name: " >&2
        read -r app_name
        echo "$app_name"
    fi
}

# Determine category through interactive questions
determine_category() {
    local app_name="$1"
    
    log_info "Determining category for '$app_name'..." >&2
    echo >&2
    
    # Ask classification questions
    echo "Please answer the following questions to help categorize '$app_name':" >&2
    echo >&2
    
    # Question 1: Primary function
    echo "1. What is the primary function of '$app_name'?" >&2
    echo "   a) Web browsing" >&2
    echo "   b) Text editing/coding" >&2
    echo "   c) Communication/messaging" >&2
    echo "   d) Design/creative work" >&2
    echo "   e) System management/configuration" >&2
    echo "   f) Development/DevOps tools" >&2
    echo "   g) Productivity/workflow" >&2
    echo "   h) Media consumption" >&2
    echo "   i) Security/privacy" >&2
    echo "   j) AI/machine learning" >&2
    echo "   k) Programming language support" >&2
    echo "   l) Terminal/shell enhancement" >&2
    echo "   m) System utilities/helpers" >&2
    echo >&2
    echo -n "Select (a-m): " >&2
    
    read -r primary_function
    
    case "$primary_function" in
        a) echo "browsers" ;;
        b) echo "editors" ;;
        c) echo "communication" ;;
        d) echo "design" ;;
        e) echo "system" ;;
        f) echo "development" ;;
        g) 
            # Sub-question for productivity vs utilities
            echo >&2
            echo "2. For productivity tools, which best describes '$app_name'?" >&2
            echo "   a) Create/manage content (notes, tasks, workflows)" >&2
            echo "   b) System UI/UX improvement or background assistance" >&2
            echo -n "Select (a-b): " >&2
            read -r prod_type
            case "$prod_type" in
                a) echo "productivity" ;;
                b) echo "utilities" ;;
                *) echo "productivity" ;;
            esac
            ;;
        h) echo "media" ;;
        i) echo "security" ;;
        j) echo "ai" ;;
        k) echo "languages" ;;
        l) echo "terminal" ;;
        m) echo "utilities" ;;
        *) 
            log_warning "Invalid selection, defaulting to 'utilities'" >&2
            echo "utilities"
            ;;
    esac
}

# Validate category
validate_category() {
    local category="$1"
    for valid_cat in "${CATEGORIES[@]}"; do
        if [[ "$category" == "$valid_cat" ]]; then
            return 0
        fi
    done
    return 1
}

# Create module directory structure
create_module_structure() {
    local category="$1"
    local app_name="$2"
    local module_dir="$DOTFILES_DIR/modules/$category/$app_name"
    
    if [[ -d "$module_dir" ]]; then
        log_error "Module directory already exists: $module_dir"
        return 1
    fi
    
    log_info "Creating module directory: $module_dir"
    mkdir -p "$module_dir"
    
    return 0
}

# Ask about installation method
ask_installation_method() {
    local app_name="$1"
    
    echo >&2
    echo "How is '$app_name' typically installed?" >&2
    echo "  1) Homebrew cask (GUI app)" >&2
    echo "  2) Homebrew package (CLI tool)" >&2
    echo "  3) Nix package (CLI tool/library)" >&2
    echo "  4) Home Manager program (with built-in config)" >&2
    echo "  5) Custom/mixed installation" >&2
    echo -n "Select installation method (1-5): " >&2
    read -r install_method
    
    case "$install_method" in
        1) echo "homebrew-cask" ;;
        2) echo "homebrew-package" ;;
        3) echo "nix" ;;
        4) echo "home-manager" ;;
        5) echo "custom" ;;
        *) echo "homebrew-cask" ;; # default
    esac
}

# Get description from brew info
get_brew_description() {
    local app_name="$1"
    local brew_type="$2"  # "package" or "cask"
    
    if command -v brew >/dev/null 2>&1; then
        local brew_info
        if [[ "$brew_type" == "cask" ]]; then
            brew_info=$(brew info --cask "$app_name" 2>/dev/null)
        else
            brew_info=$(brew info "$app_name" 2>/dev/null)
        fi
        
        if [[ $? -eq 0 && -n "$brew_info" ]]; then
            local description
            
            if [[ "$brew_type" == "cask" ]]; then
                # For casks, look for the Description section
                description=$(echo "$brew_info" | grep -A 1 "==> Description" | tail -n 1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                
                # If no Description section, try the second line
                if [[ -z "$description" ]]; then
                    description=$(echo "$brew_info" | sed -n '2p' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                fi
            else
                # For packages, description is usually the second line
                description=$(echo "$brew_info" | sed -n '2p' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            fi
            
            # If still no good description, try to find one
            if [[ -z "$description" || "$description" =~ ^https?:// || "$description" =~ ^\/ ]]; then
                # Try to find a line that looks like a description
                description=$(echo "$brew_info" | grep -v "^[[:space:]]*$" | grep -v "^==>" | grep -v "^https\?://" | grep -v "^/" | grep -v "^Installed" | grep -v "^Not installed" | grep -v "^From:" | head -n 1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            fi
            
            # Validate the description
            if [[ -n "$description" && "$description" != "$app_name"* && ! "$description" =~ ^https?:// && ! "$description" =~ ^\/ && ${#description} -gt 5 ]]; then
                echo "$description"
                return 0
            fi
        fi
    fi
    
    # Fallback to generic description
    return 1
}

# Generate module template based on installation method
generate_module_template() {
    local category="$1"
    local app_name="$2"
    local module_file="$DOTFILES_DIR/modules/$category/$app_name/default.nix"
    
    # Ask about installation method first to determine how to get description
    local install_method
    install_method=$(ask_installation_method "$app_name")
    
    # Get description based on installation method
    local description
    case "$install_method" in
        "homebrew-cask")
            if ! description=$(get_brew_description "$app_name" "cask"); then
                description="$app_name application"
            fi
            ;;
        "homebrew-package")
            if ! description=$(get_brew_description "$app_name" "package"); then
                description="$app_name tool"
            fi
            ;;
        *)
            # Fallback to category-based description for non-Homebrew methods
            case "$category" in
                "productivity") description="$app_name productivity tool" ;;
                "utilities") description="$app_name utility tool" ;;
                "development") description="$app_name development tool" ;;
                "browsers") description="$app_name web browser" ;;
                "editors") description="$app_name text editor" ;;
                "ai") description="$app_name AI application" ;;
                "communication") description="$app_name communication app" ;;
                "design") description="$app_name design tool" ;;
                "languages") description="$app_name programming language support" ;;
                "media") description="$app_name media application" ;;
                "security") description="$app_name security tool" ;;
                "system") description="$app_name system configuration" ;;
                "terminal") description="$app_name terminal tool" ;;
                *) description="$app_name application" ;;
            esac
            ;;
    esac
    
    # Generate different templates based on installation method
    case "$install_method" in
        "homebrew-cask")
            generate_homebrew_cask_template "$category" "$app_name" "$description" "$module_file"
            ;;
        "homebrew-package")
            generate_homebrew_package_template "$category" "$app_name" "$description" "$module_file"
            ;;
        "nix")
            generate_nix_template "$category" "$app_name" "$description" "$module_file"
            ;;
        "home-manager")
            generate_home_manager_template "$category" "$app_name" "$description" "$module_file"
            ;;
        "custom")
            generate_custom_template "$category" "$app_name" "$description" "$module_file"
            ;;
    esac
    
    log_success "Generated module template: $module_file"
}

# Generate Homebrew cask template
generate_homebrew_cask_template() {
    local category="$1"
    local app_name="$2"
    local description="$3"
    local module_file="$4"
    
    cat > "$module_file" << EOF
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.$category.$app_name;
in
{
  options.modules.$category.$app_name = {
    enable = mkEnableOption "$description";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [ "$app_name" ];
    };
  };
}
EOF
}

# Generate Homebrew package template
generate_homebrew_package_template() {
    local category="$1"
    local app_name="$2"
    local description="$3"
    local module_file="$4"
    
    cat > "$module_file" << EOF
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.$category.$app_name;
in
{
  options.modules.$category.$app_name = {
    enable = mkEnableOption "$description";
  };

  config = mkIf cfg.enable {
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      brews = [ "$app_name" ];
    };
  };
}
EOF
}

# Generate Nix package template
generate_nix_template() {
    local category="$1"
    local app_name="$2"
    local description="$3"
    local module_file="$4"
    
    cat > "$module_file" << EOF
{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.$category.$app_name;
in
{
  options.modules.$category.$app_name = {
    enable = mkEnableOption "$description";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      $app_name
    ];
  };
}
EOF
}

# Generate Home Manager program template
generate_home_manager_template() {
    local category="$1"
    local app_name="$2"
    local description="$3"
    local module_file="$4"
    local username_param=""
    
    # Add username parameter for home-manager modules
    if [[ "$category" != "languages" ]]; then
        username_param=", username"
    fi
    
    cat > "$module_file" << EOF
{ config, pkgs, lib$username_param, ... }:

with lib;

let
  cfg = config.modules.$category.$app_name;
in
{
  options.modules.$category.$app_name = {
    enable = mkEnableOption "$description";
  };

  config = mkIf cfg.enable {
    home-manager.users.\${username}.programs.$app_name = {
      enable = true;
      # Add configuration options here
    };
  };
}
EOF
}

# Generate custom/mixed template
generate_custom_template() {
    local category="$1"
    local app_name="$2"
    local description="$3"
    local module_file="$4"
    
    cat > "$module_file" << EOF
{ config, pkgs, lib, username, ... }:

with lib;

let
  cfg = config.modules.$category.$app_name;
in
{
  options.modules.$category.$app_name = {
    enable = mkEnableOption "$description";
  };

  config = mkIf cfg.enable {
    # Nix packages
    environment.systemPackages = with pkgs; [
      # Add CLI tools here
    ];
    
    # Homebrew apps (if needed)
    homebrew = mkIf (config.modules.system.homebrew.enable or false) {
      casks = [
        # Add GUI apps here
      ];
    };
    
    # Home Manager configuration (if needed)
    home-manager.users.\${username} = {
      # Add user-specific configuration here
    };
  };
}
EOF
}

# Validate nix syntax
validate_nix_syntax() {
    local module_file="$1"
    
    log_info "Validating Nix syntax..."
    
    if command -v nix-instantiate >/dev/null 2>&1; then
        if nix-instantiate --parse "$module_file" >/dev/null 2>&1; then
            log_success "Nix syntax validation passed"
            return 0
        else
            log_error "Nix syntax validation failed"
            return 1
        fi
    else
        log_warning "nix-instantiate not found, skipping syntax validation"
        return 0
    fi
}

# Show summary and get confirmation
show_summary() {
    local category="$1"
    local app_name="$2"
    local module_path="modules/$category/$app_name"
    
    echo >&2
    echo "=========================================" >&2
    echo "Module Creation Summary" >&2
    echo "=========================================" >&2
    echo "App Name: $app_name" >&2
    echo "Category: $category ($(get_category_desc "$category"))" >&2
    echo "Path: $module_path" >&2
    echo "Option: modules.$category.$app_name.enable" >&2
    echo "=========================================" >&2
    echo >&2
    
    echo -n "Create this module? (y/N): " >&2
    read -r confirm
    
    case "$confirm" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Main function
main() {
    # Check if help is requested
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Check if we're in the dotfiles directory
    if [[ ! -f "$DOTFILES_DIR/flake.nix" ]]; then
        log_error "Not in dotfiles directory. Please run from $DOTFILES_DIR"
        exit 1
    fi
    
    # Get app name
    local app_name
    app_name=$(get_app_name "$1")
    
    if [[ -z "$app_name" ]]; then
        log_error "App name is required"
        show_usage
        exit 1
    fi
    
    # Normalize app name (lowercase, replace spaces with dashes)
    app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    log_info "Processing app: $app_name"
    
    # Determine category
    local category
    category=$(determine_category "$app_name")
    
    # Validate category
    if ! validate_category "$category"; then
        log_error "Invalid category: $category"
        exit 1
    fi
    
    # Show summary and get confirmation
    if ! show_summary "$category" "$app_name"; then
        log_info "Module creation cancelled"
        exit 0
    fi
    
    # Create module structure
    if ! create_module_structure "$category" "$app_name"; then
        exit 1
    fi
    
    # Generate module template
    generate_module_template "$category" "$app_name"
    
    # Validate syntax
    local module_file="$DOTFILES_DIR/modules/$category/$app_name/default.nix"
    if ! validate_nix_syntax "$module_file"; then
        log_warning "Syntax validation failed, but module was created"
    fi
    
    # Add module to git
    local module_dir="modules/$category/$app_name"
    if command -v git >/dev/null 2>&1 && [[ -d "$DOTFILES_DIR/.git" ]]; then
        log_info "Adding module to git..."
        if git add "$module_dir" 2>/dev/null; then
            log_success "Module added to git staging area"
        else
            log_warning "Failed to add module to git"
        fi
    else
        log_warning "Git not available or not in a git repository"
    fi
    
    echo
    log_success "Module created successfully!"
    echo
    echo "Next steps:"
    echo "1. Edit the module file: $module_file"
    echo "2. Add to your machine configuration:"
    echo "   modules.$category.$app_name.enable = true;"
    echo "3. Test the configuration:"
    echo "   darwin-rebuild switch --flake .#<machine> --dry-run"
    echo "4. Commit the changes:"
    echo "   git commit -m \"feat($category): add $app_name module\""
    echo
}

# Run main function with all arguments
main "$@"
#!/bin/bash

# Script to remove role-related files and directories
# This is part of the migration from role-based to fzf-based module management

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Files to remove
ROLE_FILES=(
  "$DOTFILES_DIR/ROLE_SYSTEM_GUIDE.md"
  "$DOTFILES_DIR/SIMPLIFIED_ROLE_SYSTEM_GUIDE.md"
  "$DOTFILES_DIR/ROLE_PROPOSAL.md"
  "$DOTFILES_DIR/SIMPLIFIED_ROLE_PROPOSAL.md"
  "$DOTFILES_DIR/SIMPLIFIED_ROLE_SUMMARY.md"
  "$DOTFILES_DIR/MIGRATION_GUIDE.md"
)

# Check if we're in the dotfiles directory
if [ ! -f "$DOTFILES_DIR/flake.nix" ]; then
    log_error "Not in dotfiles directory. Please run from $DOTFILES_DIR"
    exit 1
fi

# Confirm before removing files
echo "The following role-related files will be removed:"
for file in "${ROLE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  - $(basename "$file")"
    fi
done

echo
echo -n "Do you want to proceed? (y/N): "
read -r confirm

if [[ "$confirm" != [Yy]* ]]; then
    log_info "Operation cancelled"
    exit 0
fi

# Remove files
for file in "${ROLE_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_info "Removing $(basename "$file")..."
        rm "$file"
        if [ $? -eq 0 ]; then
            log_success "Removed $(basename "$file")"
        else
            log_error "Failed to remove $(basename "$file")"
        fi
    fi
done

# Check for roles directory
ROLES_DIR="$DOTFILES_DIR/roles"
if [ -d "$ROLES_DIR" ]; then
    log_info "Found roles directory: $ROLES_DIR"
    echo -n "Do you want to remove the roles directory and all its contents? (y/N): "
    read -r confirm_dir
    
    if [[ "$confirm_dir" == [Yy]* ]]; then
        log_info "Removing roles directory..."
        rm -rf "$ROLES_DIR"
        if [ $? -eq 0 ]; then
            log_success "Removed roles directory"
        else
            log_error "Failed to remove roles directory"
        fi
    else
        log_info "Roles directory will be kept"
    fi
fi

# Check for role references in machine configurations
log_info "Checking for role references in machine configurations..."
MACHINES_DIR="$DOTFILES_DIR/machines"
ROLE_REFERENCES=()

for machine_dir in "$MACHINES_DIR"/*; do
    if [ -d "$machine_dir" ]; then
        machine_config="$machine_dir/default.nix"
        if [ -f "$machine_config" ] && grep -q "roles" "$machine_config"; then
            ROLE_REFERENCES+=("$machine_config")
        fi
    fi
done

if [ ${#ROLE_REFERENCES[@]} -gt 0 ]; then
    log_warning "Found role references in the following machine configurations:"
    for config in "${ROLE_REFERENCES[@]}"; do
        echo "  - $config"
    done
    echo
    echo "You should manually update these files to remove role references."
    echo "Use the fzf-module.sh script to manage modules directly instead."
else
    log_success "No role references found in machine configurations"
fi

log_success "Role cleanup completed"
echo
echo "Next steps:"
echo "1. Use ./scripts/fzf-module.sh to manage modules"
echo "2. Update README.md with content from README_UPDATE.md"
echo "3. Remove this script when no longer needed"
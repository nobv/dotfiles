#!/bin/bash

# Script to find mismatches between directory paths and module names in Nix files

echo "Finding module name mismatches..."
echo "=================================="

find_mismatches() {
  find modules -name "default.nix" | while read file; do
    # Skip the neovim plugins file as it has a different structure
    if [[ "$file" == "modules/editors/neovim/lua/plugins/default.nix" ]]; then
      continue
    fi
    
    # Extract directory path without 'modules/' prefix and convert to dot notation
    dir_path=$(dirname "$file" | sed 's|^modules/||' | tr '/' '.')
    
    # Extract module name from the file
    module_name=$(grep -E "cfg = config\.modules\.[a-zA-Z0-9._-]+" "$file" | sed -E 's/.*config\.modules\.([a-zA-Z0-9._-]+).*/\1/')
    
    # If module name doesn't match directory path and module name is not empty
    if [ "$dir_path" != "$module_name" ] && [ ! -z "$module_name" ]; then
      echo "Mismatch in $file:"
      echo "  Directory path: modules.$dir_path"
      echo "  Module name:    modules.$module_name"
      echo ""
    fi
  done
}

find_mismatches
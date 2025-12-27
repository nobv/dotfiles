#!/bin/bash

# Script to automatically fix module name mismatches in Nix files

echo "Fixing module name mismatches..."
echo "================================"

fix_mismatches() {
  find modules -name "default.nix" | while read file; do
    # Extract directory path without 'modules/' prefix and convert to dot notation
    dir_path=$(dirname "$file" | sed 's|^modules/||' | tr '/' '.')
    
    # Extract module name from the file
    module_name=$(grep -E "cfg = config\.modules\.[a-zA-Z0-9._-]+" "$file" | sed -E 's/.*config\.modules\.([a-zA-Z0-9._-]+).*/\1/')
    
    # If module name doesn't match directory path
    if [ "$dir_path" != "$module_name" ]; then
      echo "Fixing mismatch in $file:"
      echo "  Directory path: modules.$dir_path"
      echo "  Old module name: modules.$module_name"
      
      # Replace module name in the file
      sed -i '' "s/config\.modules\.$module_name/config.modules.$dir_path/g" "$file"
      sed -i '' "s/options\.modules\.$module_name/options.modules.$dir_path/g" "$file"
      
      echo "  New module name: modules.$dir_path"
      echo ""
    fi
  done
}

fix_mismatches
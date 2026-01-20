#!/bin/bash

echo "Fixing module mismatches and rebuilding configuration..."
echo "======================================================="

# Run the fix_module_mismatches.sh script
./fix_module_mismatches.sh

# Clean any previous build artifacts
rm -rf result

# Rebuild the configuration
echo "Rebuilding the configuration..."
sudo darwin-rebuild switch --flake .#macbook
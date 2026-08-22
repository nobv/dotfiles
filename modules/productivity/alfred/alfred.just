# Alfred recipes. Kept with the module because the manifest, the script and the
# preferences bundle they drive are right here; recipes still run from the repo
# root.
set working-directory := '../../..'

# Install the workflows listed in workflows.txt that this machine is missing (idempotent; no-op runs make no network requests)
sync:
    ./modules/productivity/alfred/workflows.sh sync

# Record workflows installed here but missing from workflows.txt (commit the diff afterwards)
add:
    ./modules/productivity/alfred/workflows.sh add

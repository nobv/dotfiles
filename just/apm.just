# apm (Agent Package Manager) recipes. Run from the repo root (modules live under just/).
set working-directory := '..'

# Install apm packages from the lockfile (read-only; fails on lockfile drift)
sync:
    apm install --frozen -g

# Resolve apm.yml and rewrite the lockfile (no version bump, no deploy)
lock:
    cd modules/ai/apm && apm lock

# Refresh apm dependencies and regenerate the lockfile (commit the diff)
update:
    apm update

# Show outdated apm dependencies
outdated:
    apm outdated -g

# Audit apm installation integrity and drift
audit:
    apm audit

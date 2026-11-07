set working-directory := '../../..'

# Preview claude-mem hook repairs; pass --apply to replace the listed symlinks
repair-hooks *ARGS:
    python3 modules/ai/codex/repair-hooks.py {{ARGS}}

# Check repair behavior against disposable plugin fixtures
test:
    python3 -m unittest discover -s modules/ai/codex/tests -v

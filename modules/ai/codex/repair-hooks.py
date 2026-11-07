#!/usr/bin/env python3
"""Repair claude-mem .bin symlinks rejected by Codex plugin fingerprinting.

Temporary workaround for https://github.com/openai/codex/issues/56520.
Default to a read-only preview; never modify hook approvals.
"""

import argparse
import json
import os
from pathlib import Path
import shlex
import sys
import tempfile


def plan_repairs(root):
    if root.is_symlink() or not root.is_dir():
        raise ValueError(f"Plugin root must be a real directory: {root}")
    root = root.resolve(strict=True)
    manifest = root / ".codex-plugin" / "plugin.json"
    metadata = json.loads(manifest.read_text())
    if not isinstance(metadata, dict) or metadata.get("name") != "claude-mem":
        raise ValueError(f"Not a claude-mem plugin: {root}")

    repairs = []

    def walk_error(error):
        raise error

    for directory, dirs, files in os.walk(root, followlinks=False, onerror=walk_error):
        dirs.sort()
        for name in sorted(dirs + files):
            link = Path(directory) / name
            if not link.is_symlink():
                continue
            # Refuse unfamiliar links instead of silently leaving a broken bundle.
            if link.parent.name != ".bin" or link.parent.parent.name != "node_modules":
                raise ValueError(f"Unsupported symlink; no repairs applied: {link}")
            original = os.readlink(link)
            target = link.resolve(strict=True)
            if not target.is_relative_to(root):
                raise ValueError(f"Symlink leaves plugin; no repairs applied: {link}")
            if not target.is_file() or not os.access(target, os.X_OK):
                raise ValueError(f"Target must be an executable file: {link}")
            relative = os.path.relpath(target, link.parent)
            wrapper = '#!/bin/sh\nexec "$(dirname "$0")"/' + shlex.quote(relative) + ' "$@"\n'
            repairs.append((link, original, wrapper))
    return repairs


def replace_link(link, original, wrapper):
    # Replace the directory entry atomically. Writing through the symlink would
    # overwrite its target; keeping a backup symlink inside the bundle also fails
    # Codex's fingerprint check.
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=link.parent, prefix=".codex-hook-repair-", delete=False
        ) as output:
            temporary = Path(output.name)
            output.write(wrapper)
            output.flush()
            os.fchmod(output.fileno(), 0o755)
            os.fsync(output.fileno())
        if not link.is_symlink() or os.readlink(link) != original:
            raise ValueError(f"Symlink changed during repair; rerun the command: {link}")
        os.replace(temporary, link)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true", help="apply the repairs")
    mode.add_argument("--dry-run", action="store_true", help="preview only (default)")
    parser.add_argument(
        "--plugin-root",
        type=Path,
        help="repair one claude-mem version directory instead of discovering the cache",
    )
    args = parser.parse_args()
    codex_home = Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex").expanduser()
    if args.plugin_root:
        roots = [args.plugin_root.expanduser()]
    else:
        roots = sorted((codex_home / "plugins" / "cache").glob("*/claude-mem/*"))
    if not roots:
        print("No cached claude-mem plugins found.")
        return 0

    # Preflight every version before changing any of them.
    try:
        repairs = [repair for root in roots for repair in plan_repairs(root)]
        for link, original, wrapper in repairs:
            print(f"{'Repair' if args.apply else 'Would repair'}: {link} -> {original}", flush=True)
            if args.apply:
                replace_link(link, original, wrapper)
    except (OSError, ValueError, RuntimeError) as error:
        print(f"Repair failed: {error}", file=sys.stderr)
        return 1

    if not repairs:
        print("No symlinks need repair.")
    elif args.apply:
        print(f"Repaired {len(repairs)} symlink(s). Review and reapprove in Codex /hooks if requested.")
    else:
        print(f"Dry run: {len(repairs)} symlink(s). Rerun with --apply to repair.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

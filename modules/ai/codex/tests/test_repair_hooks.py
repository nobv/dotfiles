"""Exercise the repair CLI using disposable plugins, never the live cache."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "repair-hooks.py"


class RepairHooksTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.root = self.plugin("1.0.0")

    def plugin(self, version):
        root = self.home / "plugins/cache/test-market/claude-mem" / version
        manifest = root / ".codex-plugin/plugin.json"
        manifest.parent.mkdir(parents=True)
        manifest.write_text(json.dumps({"name": "claude-mem"}))
        return root

    def executable(self, path):
        path.parent.mkdir(parents=True, exist_ok=True)
        # Target locates a sibling resource, making a copied script incorrect.
        path.write_text(
            '#!/usr/bin/env python3\nimport sys\nfrom pathlib import Path\n'
            'sys.stdout.write((Path(__file__).resolve().parent / "resource").read_text())\n'
            'for argument in sys.argv[1:]:\n    print(argument)\n'
        )
        path.chmod(0o755)
        (path.parent / "resource").write_text("resource from target\n")
        return path

    def link(self, root=None, package="tool", name="tool"):
        root = root or self.root
        target = self.executable(root / "node_modules" / package / "bin")
        link = root / "node_modules/.bin" / name
        link.parent.mkdir(parents=True, exist_ok=True)
        link.symlink_to(os.path.relpath(target, link.parent))
        return link, target

    def run_cli(self, *args, success=True):
        result = subprocess.run(
            [sys.executable, str(SCRIPT), *args],
            env={**os.environ, "CODEX_HOME": str(self.home)},
            capture_output=True, text=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0 if success else 1, result.stdout + result.stderr)
        return result

    def test_preview_preserves_link_and_target(self):
        link, target = self.link()
        before = target.read_bytes()
        for args in [(), ("--dry-run",)]:
            result = self.run_cli(*args)
            self.assertIn("Would repair:", result.stdout)
            self.assertTrue(link.is_symlink())
            self.assertEqual(target.read_bytes(), before)

    def test_apply_preserves_arguments_resources_and_target_then_is_idempotent(self):
        link, target = self.link(package="tool 'quoted'", name="tool with spaces")
        args = ["a b", "'quoted'", "", "$(touch unwanted)", "--flag"]
        expected = subprocess.check_output([str(link), *args])
        original = target.read_bytes()
        self.run_cli("--apply")
        self.assertFalse(link.is_symlink())
        self.assertTrue(os.access(link, os.X_OK))
        self.assertEqual(subprocess.check_output([str(link), *args]), expected)
        self.assertEqual(target.read_bytes(), original)
        before = link.read_bytes(), link.stat().st_mtime_ns
        self.assertIn("No symlinks need repair", self.run_cli("--apply").stdout)
        self.assertEqual((link.read_bytes(), link.stat().st_mtime_ns), before)
        self.assertFalse(list(link.parent.glob(".codex-hook-repair-*")))

    def test_all_versions_and_nested_bin_directories_are_repaired(self):
        first, _ = self.link()
        second, _ = self.link(self.plugin("2.0.0"))
        nested, _ = self.link(self.root / "node_modules/grammar")
        self.run_cli("--apply")
        self.assertTrue(all(not link.is_symlink() for link in [first, second, nested]))

    def test_preflight_rejects_unsafe_links_without_partial_repairs(self):
        good, _ = self.link()
        bad = self.plugin("2.0.0") / "node_modules/.bin/bad"
        bad.parent.mkdir(parents=True)
        for kind in ["external", "dangling", "directory", "non-executable", "cycle"]:
            with self.subTest(kind=kind):
                target = bad.parent.parent / "target"
                if kind == "external":
                    target = self.executable(self.home / "outside/bin")
                elif kind == "dangling":
                    target = self.home / "missing"
                elif kind == "directory":
                    target.mkdir(exist_ok=True)
                elif kind == "non-executable":
                    target = bad.parent.parent / "non-executable"
                    target.write_text("not executable")
                    target.chmod(0o644)
                else:
                    target = bad
                bad.symlink_to(target)
                self.run_cli("--apply", success=False)
                self.assertTrue(good.is_symlink())
                self.assertTrue(bad.is_symlink())
                bad.unlink()

    def test_unfamiliar_symlink_prevents_repairs(self):
        link, target = self.link()
        (self.root / "another-link").symlink_to(target)
        self.run_cli("--apply", success=False)
        self.assertTrue(link.is_symlink())

    def test_explicit_root_and_absent_cache(self):
        link, _ = self.link()
        self.run_cli("--plugin-root", str(self.root), "--apply")
        self.assertFalse(link.is_symlink())
        result = self.run_cli("--plugin-root", str(self.home / "missing"), success=False)
        self.assertIn("Plugin root", result.stderr)
        empty = self.home / "empty-home"
        empty.mkdir()
        self.home = empty
        self.assertIn("No cached", self.run_cli("--apply").stdout)


if __name__ == "__main__":
    unittest.main()

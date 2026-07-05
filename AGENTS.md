# Repository Guidelines

This repository's canonical agent instructions live in `CLAUDE.md`.

When working in this repository, read and follow `CLAUDE.md` before making changes. Treat it as the source of truth for architecture, module conventions, validation commands, worktree workflow, commit style, and safety rules.

Key non-negotiables:

- Use the existing Nix module pattern: `options.modules.<category>.<name>.enable` with `config = mkIf cfg.enable`.
- Keep modules self-contained under `modules/<category>/<name>/default.nix`.
- For Homebrew-backed modules, guard Homebrew config with `mkIf (config.modules.system.homebrew.enable or false)`.
- Validate config changes with `nix flake check` / `just nix check` and a rootless build where appropriate.
- Do not apply system changes without an explicit dry run.
- Do not commit local-only `machines/<machine>/config.nix` files.

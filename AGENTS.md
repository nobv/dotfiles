# Repository Guidelines

## Project Structure & Module Organization
This repository is a Nix Darwin + Home Manager setup organized around modular configuration.

- `flake.nix`: flake entrypoint and module auto-discovery.
- `machines/`: per-machine configs (`default.nix`, `darwin.nix`, `home.nix`) plus local-only `config.nix` (not tracked, e.g. `machines/work/config.nix`).
- `modules/`: feature modules grouped by category (for example `modules/development/`, `modules/terminal/`, `modules/utilities/`). Each module lives at `modules/<category>/<name>/default.nix`.
- `scripts/`: helper scripts (for example `scripts/enable-module.sh`).
- `overlays/`: custom Nixpkgs overlays.

## Build, Test, and Development Commands
- `nix flake check`: validate flake syntax and evaluation.
- `nix build .#darwinConfigurations.<machine>.system`: build a system configuration without applying.
- `darwin-rebuild switch --flake .#<machine> --dry-run`: required validation step before applying changes.
- `darwin-rebuild switch --flake .#<machine>`: apply configuration after a clean dry run.
- `nix develop`: enter the dev shell (includes `nixpkgs-fmt`, `nix-tree`).
- `./scripts/enable-module.sh [machine]`: interactive module enable/disable.

## Coding Style & Naming Conventions
- Nix formatting: run `nixpkgs-fmt` on `.nix` files.
- Module options follow `options.modules.<category>.<name>.enable` and gate config with `mkIf cfg.enable`.
- Keep modules self-contained; add new ones under `modules/<category>/<name>/default.nix`.
- Shell scripts live in `scripts/` or `bin/` and should remain readable and minimal.

## Testing Guidelines
- There is no unit test suite; validation is configuration-focused.
- Always run `nix flake check` and `darwin-rebuild switch --flake .#<machine> --dry-run` for config changes.
- If you update inputs (`nix flake update`), re-run the dry run before applying.

## Commit & Pull Request Guidelines
- Commit messages follow Conventional Commits (observed in history): `feat(scope): ...`, `refactor(scope): ...`, `chore(scope): ...`.
- Keep commits single-line and scoped when useful.
- PRs should describe the affected machine/module, include the dry-run command used, and link related issues when applicable.

## Security & Configuration Tips
- `machines/<machine>/config.nix` is local-only and contains your username; do not commit it (for example `machines/work/config.nix`).
- Always validate with `--dry-run` before applying to avoid system breakage.

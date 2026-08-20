# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ This repository is PUBLIC

`github.com/nobv/dotfiles` is a public repository. **Everything committed here is world-readable, permanently, including anything removed in a later commit.** Treat this as a hard constraint, not a preference.

**Never commit personal or identifying information**, including but not limited to:

- Email addresses, domain names, company names, real names
- Calendar names, account names, machine hostnames, network SSIDs
- File paths that embed any of the above
- API keys, tokens, license keys, or anything else secret
- Screenshots, logs, or example output containing the above

This applies to code, comments, commit messages, PR titles and descriptions alike. Use placeholders in examples — `acme.example`, `user@example.com` (`.example` is reserved by RFC 2606 and cannot exist).

**When a feature genuinely needs personal values, do not commit them.** Read them at runtime from somewhere outside the repository instead:

- Another app's settings (`defaults read <bundle-id> <key>`)
- A gitignored local file
- The environment, or a private config the tool already owns

Example: the sketchybar calendar item reads which calendars to show from MeetingBar's own preferences at runtime, because calendar names on this machine are email addresses. The repository holds only the logic.

**Before committing, grep the diff for identifiers.** They arrive most often through example output pasted into comments or PR descriptions, not through code.

## Architecture Overview
This is a Nix Darwin configuration using flakes and Home Manager for macOS system and user environment management. The architecture consists of:

- **Flake-based configuration** (`flake.nix`) with machine-specific Darwin configurations
- **Option-based module system** where all modules use `options.modules.<category>.<name>.enable` pattern
- **Self-contained machine configs** in `machines/` that include both Darwin and Home Manager settings
- **Auto-discovery system**: Modules are automatically imported from the modules directory
- **Conditional module loading** via options system for clean, maintainable configurations

## Quick Start Commands

### just commands (recommended)
The `Justfile` uses modules under `just/`. Recipes are invoked as `just <module> <recipe>` (e.g. `just apm lock`); the `::` form (`just apm::lock`) is equivalent. Run `just` to list everything, `just --list <module>` for one group.
- Apply everything (ff `main` → switch → apm sync → claude plugins): `just apply`
- Apply configuration: `just nix switch`
- Build without root (worktree-safe validation): `just nix build`
- Dry-run activation (needs root; pre-`switch` check on `main`): `just nix dry-run`
- Check flake: `just nix check`
- Format Nix files: `just nix fmt`
- Update all inputs: `just nix update` (one input: `just nix update-input <input-name>`)
- Show flake info: `just nix show`
- Interactive module management: `just nix modules`
- Enter development shell: `just nix dev`
- Fast-forward `main`: `just git sync`
- apm: `just apm sync` (install locked) · `just apm lock` (relock) · `just apm update` · `just apm outdated` · `just apm audit`
- Claude native plugins: `just claude plugins` (primary config dir + every profile under `~/.config/claude/profiles/*`)

To target a different machine, set the env var (CLI `MACHINE=…` does not work across modules): `DOTFILES_MACHINE=work just nix switch`

### Daily Development Commands
- Dry-run activation (needs root; pre-`switch` check on `main`): `darwin-rebuild switch --flake .#<machine> --dry-run`
- Apply configuration: `darwin-rebuild switch --flake .#<machine>`
- Interactive module management: `./scripts/enable-module.sh [machine]`
- List all modules and status: `./scripts/enable-module.sh --list`

### Build and Validation Commands
- Check flake: `nix flake check`
- Build system configuration (rootless validation — use this inside a worktree): `nix build .#darwinConfigurations.<machine>.system`
- Enter development shell: `nix develop`
- Show flake info: `nix flake show`

### Flake Management
- Update all inputs: `nix flake update`
- Update specific input: `nix flake lock --update-input <input-name>` (e.g., `nixpkgs`, `home-manager`)
- Show flake metadata: `nix flake metadata`

**IMPORTANT**: Validate every change before it touches the live system (see Development Workflow). Inside a worktree use the rootless `just nix build` (`nix build .#darwinConfigurations.<machine>.system`); `just nix dry-run` / `darwin-rebuild … --dry-run` need root and are for the pre-`switch` check on `main`.

## Installation Commands
- One-liner install: `bash -c "$(curl -L https://raw.githubusercontent.com/nobv/dotfiles/main/install)"`
- Manual install: `./setup.sh -m <machine>` (after cloning repo)
- Skip Homebrew: `./setup.sh -m <machine> --skip-homebrew`

## Machine Configurations
Available machine configurations:
- `macbook` - Development-focused setup for MacBook (tmux, docker, python, etc.)
- `macmini` - Desktop setup for Mac Mini (emacs, lighter dev tools)
- `work` - Full development stack for work environment

Example usage:
- `darwin-rebuild switch --flake .#macbook --dry-run` (test first)
- `darwin-rebuild switch --flake .#macbook` (then apply)
- `darwin-rebuild switch --flake .#work`
- `darwin-rebuild switch --flake .#macmini`

## Machine-Specific Configuration
- Each machine requires `machines/<machine>/config.nix`, format `{ username = "your-username"; }`
- **`username` is the only key read.** `flake.nix` (`mkDarwinSystem`) destructures nothing else, and it is
  the sole value threaded into modules via `specialArgs`. Adding `hostname` or `gitEmail` there has no effect
  unless `flake.nix` is taught to read them
- **These files ARE tracked in git**, and the three machines are not consistent about it:
  - `machines/macbook/config.nix`, `machines/macmini/config.nix` — real username committed
  - `machines/work/config.nix` — the `REPLACE_WITH_YOUR_USERNAME` placeholder is committed, and the real
    username lives only as a permanent uncommitted modification on that machine. So a fresh `nix build` in a
    worktree fails for `work` until you write the username in locally (do not commit it)
- `machines/.gitignore` carries a **commented-out** `work/config.nix` rule, which is why the file is
  tracked despite `setup.sh` describing it as git-ignored

### Configuration Setup
**Automatic (Recommended):**
- Run `./setup.sh -m <machine>` — it writes `config.nix` inline (heredoc, `setup.sh:132-139`) when missing,
  then prompts for the username and `sed`s out the placeholder. There is no `templates/` directory

**Manual Setup:**
1. Create `machines/<machine>/config.nix` with the format above
2. Replace `REPLACE_WITH_YOUR_USERNAME` with your actual username

## Interactive Module Management

The `scripts/enable-module.sh` script provides an interactive interface for managing modules:

**Usage:**
- Interactive mode: `./scripts/enable-module.sh` (auto-detects machine)
- Specific machine: `./scripts/enable-module.sh macbook`
- List all modules: `./scripts/enable-module.sh --list`
- Help: `./scripts/enable-module.sh --help`

**Features:**
- Browse modules by category (ai, browsers, development, etc.)
- View current status: enabled ✅, disabled ❌, or available 🆕
- Select multiple modules for bulk enable/disable
- Paginated display for categories with many modules
- Automatic validation of Nix configuration syntax
- Backup and rollback on validation failure

**Navigation:**
- Numbers: Select module to toggle
- Space: Toggle all visible modules on current page
- Enter: Apply selected changes
- c: Clear selections
- n/p: Next/previous page
- q: Back to categories

## Module System Architecture
- **Self-contained machine configs**: Each `machines/<machine>/default.nix` contains complete Darwin + Home Manager config
- **Centralized module discovery**: Module auto-discovery logic is shared in `flake.nix` and applied to all machines
- **Module structure**: Each module in `modules/` defines `options.modules.<category>.<name>` and conditional `config`
- **Individual app modules**: All applications are split into individual modules for fine-grained control
- **Homebrew dependency**: Apps using Homebrew wrap their config with `mkIf (config.modules.system.homebrew.enable or false)`
- **Machine config structure**: Each machine has `default.nix` (module selections), `darwin.nix` (system config), `home.nix` (user config), and `config.nix` (username)
- **DRY principle**: No code duplication between machine configs

## Module Development Guidelines
- **Module pattern**: Follow the established pattern: function signature → `with lib;` → `cfg` binding → `options` → `config = mkIf cfg.enable`
- **Option naming**: Use `options.modules.<category>.<name>.enable = mkEnableOption "<description>"`
- **Conditional config**: Wrap all functionality in `config = mkIf cfg.enable { ... }`
- **Homebrew dependency**: For modules using Homebrew, wrap homebrew config with `mkIf (config.modules.system.homebrew.enable or false)`
- **File organization**: Place modules in appropriate functional categories (see Module Categories below)
- **Adding new modules**: Simply create the module in appropriate category directory - it will be auto-discovered
- **Ignore rules**: Put module-specific ignores in a `.gitignore` inside the module directory (paths relative to it). The root `.gitignore` is for repository-wide rules only

## Commit Guidelines
- Use Conventional Commits: `<type>(<optional scope>): <description>`
- Keep commit messages to a single line only
- **Do not include** Claude Code attribution (`🤖 Generated with...` or `Co-Authored-By: Claude`) in commit messages
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Examples: `feat(homebrew): add packages`, `fix(wezterm): correct config`, `chore: update .gitignore`

## Development Workflow

All code-changing work happens inside a `workmux` worktree, is validated rootless, and is applied only after merging to `main`.

### When to use a worktree
- **Enter**: feature additions, bug fixes, multi-file changes, refactors
- **Skip**: questions/investigation only, a single trivial edit, a config value tweak, a typo fix

### Change flow
1. Create the worktree: `workmux add <type>/<short-kebab-description>` following Conventional Commits (e.g. `workmux add feat/todoist-mcp`); same types as commits. Unlike the legacy `EnterWorktree` tool, the branch name is used **as-is** — no `worktree-` prefix, no `/`→`+` mangling — so it's already Conventional Commits–compliant and never needs renaming. This creates the worktree under `~/.workmux/dotfiles/<handle>` (see `.workmux.yaml` for pane layout and file operations) and switches the current tmux window to it.
2. Implement inside the worktree — edit modules in `modules/<category>/<module>/default.nix`.
3. Validate **without root**, entirely within the worktree:
   - `just nix check` (`nix flake check`) — syntax
   - `just nix build` (`nix build .#darwinConfigurations.<machine>.system`) — full build, no root

   Do **not** use `just nix dry-run` / `darwin-rebuild … --dry-run` here — they require root and activate against the live system.
4. Commit to the worktree's branch (Conventional Commits, single line). To split unrelated changes into separate commits, ask for it explicitly (e.g. "commit this as two separate changes") — git-surgeon stages the hunks non-interactively instead of committing whole files.
5. Push and open a PR (`gh pr create`, or workmux's `open-pr` skill). Merge on GitHub. **`workmux merge` is not used** — merging stays PR-based so review history lives on GitHub, not in a local rebase/squash.
6. After merging into `main`, apply with `just nix switch` (or `just apply` to also ff `main` + apm sync + claude plugins) — **never `switch` from a worktree** (`mkOutOfStoreSymlink` / `dotfilesPath` point at the `main` checkout, so switching from a worktree is inconsistent).
7. Once the PR is merged, clean up: `workmux rm <name>`, or sweep everything at once with `workmux rm --gone` (removes every worktree whose upstream branch GitHub deleted on merge).

### Adding a new module
1. Create `modules/<category>/<module-name>/`
2. Add `default.nix` following the module pattern (see Module Development Guidelines)
3. It is auto-discovered — no `flake.nix` changes needed
4. Enable it in the machine config via `./scripts/enable-module.sh` or by editing `machines/<machine>/default.nix`

### Parking an unrelated task (Todoist)
If, while working in a worktree, the user starts an **unrelated** task:
- Do NOT exit the worktree, create another worktree, or spawn a sub-agent (keeps the current work visible)
- File the unrelated task as a Todoist ticket via the Todoist MCP task-creation tool (concise title; context in the body — which conversation, which files)
- Report briefly ("Filed '<task>' in Todoist; continuing current work") and keep working in the current worktree
- Pick it up later in its own worktree; continuations/spin-offs of the *current* task are NOT parked — keep them here

### Notes
- `workmux add` defaults to branching from `origin/main`; the `wm` zsh function (`modules/terminal/zsh/.zshrc`) runs `git fetch origin` before every `add` so the branch point is current — workmux itself never fetches
- `workmux add -b -P <file>` starts the agent in the background with a prompt preloaded from a file, for delegating several tasks in parallel without leaving the current window
- Tmux prefix bindings (`modules/terminal/tmux`): `C-s`/`C-w` open the workmux dashboard (all worktrees / worktrees tab), `C-t` toggles the sidebar, `L` jumps to the last completed-or-waiting agent, `Tab` toggles back to the previously visited one
- After a crash, `workmux resurrect` restores worktree windows from persisted state
- Merges happen only on explicit user request; once the work is merged, remove the worktree with `workmux rm <name>` rather than leaving it on disk
- The dev shell (`just nix dev` / `nix develop`) provides `nixpkgs-fmt` and `nix-tree`
- Todoist MCP is managed declaratively via apm (`modules/ai/apm/apm.yml` → `mcp: doist/todoist-ai`); `just apm sync` deploys it to user scope (`~/.claude.json`), available across all projects. `/mcp` authentication may be needed once

## Repository Structure
- `flake.nix`: Main entry point with auto-discovery logic
- `install`: One-liner bootstrap script (curl-compatible)
- `setup.sh`: Full installation script (sources shared utilities)
- `scripts/lib.sh`: Shared utilities (logging, macOS check, constants)
- `machines/`: Machine-specific configurations (each has default.nix, darwin.nix, home.nix, config.nix)
- `modules/`: Reusable configuration modules organized by functional categories
- `overlays/`: Nixpkgs overlays for custom packages

## Module Categories
Modules are organized by function for intuitive discovery and management:
- `ai/`: AI applications (claude, chatgpt, perplexity, poe)
- `browsers/`: Web browsers (chrome, firefox, arc, microsoft-edge)
- `communication/`: Communication apps (slack, discord, zoom, telegram, deepl)
- `design/`: Design and creative tools (figma, blender, miro)
- `development/`: Development tools and CLI utilities (docker, git, postman, xcode, aws, kubernetes, etc.)
- `editors/`: Text editors (vim, emacs, neovim, vscode, cursor, typora)
- `languages/`: Programming language environments (python, nodejs, rust, go, etc.)
- `media/`: Media and entertainment (spotify, kindle)
- `productivity/`: Productivity tools (notion, obsidian, things3, amphetamine, etc.)
- `security/`: Security tools (1password, 1password-cli, ssh, wireguard)
- `system/`: System-level configurations (homebrew, aerospace, fonts)
- `terminal/`: Terminal and shell configurations (zsh, starship, wezterm)
- `utilities/`: General utilities (raycast, karabiner-elements, flux, etc.)
- `checkers/`: Code quality and linting tools

## Homebrew Module Architecture
The Homebrew module serves as the foundational package manager:
- **Base functionality**: Provides core Homebrew configuration (brewPrefix, onActivation, global settings)
- **Individual app modules**: Each application has its own module with conditional Homebrew dependencies
- **Dependency pattern**: Apps use `mkIf (config.modules.system.homebrew.enable or false)` to conditionally enable Homebrew packages
- **Fine-grained control**: Users can enable/disable individual applications while maintaining Homebrew as the foundation

## Module Configuration Examples
```nix
# Machine configuration using actual directory structure paths
modules = {
  # System tools (options.modules.system.*)
  system = {
    homebrew.enable = true;
    fonts.enable = true;
  };
  
  # Development tools (options.modules.development.*)
  development = {
    docker.enable = true;
    git.enable = true;
    tmux.enable = true;
  };
  
  # Programming languages (options.modules.languages.*)
  languages = {
    python.enable = true;
    nodejs.enable = true;
    rust.enable = true;
  };
  
  # Text editors (options.modules.editors.*)
  editors = {
    neovim.enable = true;
    vim.enable = true;
    jetbrains.enable = true;
  };
  
  # Terminal configuration (options.modules.terminal.*)
  terminal = {
    starship.enable = true;
    zsh.enable = true;
    wezterm.enable = true;
  };
  
  # Utilities (options.modules.utilities.*)
  utilities = {
    raycast.enable = true;
    karabiner-elements.enable = true;
  };
  
  # Security (options.modules.security.*)
  security = {
    "1password".enable = true;
  };
  
  # Code quality (options.modules.checkers)
  checkers.enable = true;
};
```

## Troubleshooting

### Configuration Validation Failures
If `darwin-rebuild` fails with validation errors:
1. Check syntax: `nix flake check`
2. Review recent changes to module files
3. Verify balanced braces in edited `.nix` files
4. Check that module options follow correct naming: `options.modules.<category>.<name>.enable`

### Username Placeholder Error
Error: `Please update machines/<machine>/config.nix with your actual username`
- Edit `machines/<machine>/config.nix`
- Replace `REPLACE_WITH_YOUR_USERNAME` with your actual username
- Or run `./setup.sh -m <machine>` to regenerate config
- **Resolved automatically for `workmux add` worktrees**: `.workmux.yaml`'s `files.copy` copies the real
  `machines/work/config.nix` from `main` into every new worktree, since the placeholder is what's committed
  (see Machine-Specific Configuration). Only hits worktrees created some other way (e.g. a bare
  `git worktree add`) — in that case, write the username into the worktree's copy and leave it unstaged

### Module Not Found After Adding
If a new module isn't recognized:
1. Ensure `default.nix` exists in `modules/<category>/<module-name>/`
2. Run `nix flake check` to verify syntax
3. Check that category exists in the auto-discovery list in `flake.nix` (line 60-74)

### Homebrew Dependencies Not Installing
If apps requiring Homebrew don't install:
1. Verify `modules.system.homebrew.enable = true` in machine config
2. Check module wraps homebrew config with: `mkIf (config.modules.system.homebrew.enable or false)`
3. Run `darwin-rebuild` to apply Homebrew configuration

### Build Fails After Flake Update
If builds fail after updating inputs:
1. Check `flake.lock` for the changes: `git diff flake.lock`
2. Try updating inputs individually to isolate the issue
3. Rollback lock file: `git checkout flake.lock`
4. Report compatibility issues to the respective input repository

### `just apm sync` / `just apply` Fails with "package manifest not found"
This is a known regression introduced in apm 0.27.0: [microsoft/apm#2443](https://github.com/microsoft/apm/issues/2443) (open, accepted, fix PRs #2446/#2492 not yet merged as of v0.28.0). 0.27.0's `_enforce_frozen` added an MCP config validation pass that checks every locked dependency for an `apm.yml`. The exemption for packages that ship no `apm.yml` by design (`_allows_missing_manifest`) is gated behind `is_virtual_subdirectory()`, so a **repo-root `claude_skill`** (repo root holds `SKILL.md`, no `apm.yml` — e.g. `currents-dev/playwright-best-practices-skill`) gets rejected before its on-disk shape is ever probed. This only fires when the project also declares `mcp:` servers (`check_mcp` must be true) — in this repo `currents-dev/playwright-best-practices-skill` is the only dependency shaped that way. Plain `apm install -g` (no `--frozen`) still succeeds, and `apm audit` reports `No drift detected` — the lockfile is not actually stale, so the error's own advice (`re-run 'apm install' to restore it`) can never resolve it.
- Workaround: pin Homebrew's `apm` at 0.26.0 (the last version before the regression; do not use 0.25.0 — 0.26.0 also carries an unrelated `is_virtual` audit fix from #2214 that's worth keeping):
  ```sh
  TAP_PATH=$(brew --repository microsoft/apm)
  cd "$TAP_PATH" && git log --oneline -- Formula/apm.rb   # find the v0.26.0 commit
  git checkout <commit> -- Formula/apm.rb
  brew uninstall apm && brew install microsoft/apm/apm
  git checkout HEAD -- Formula/apm.rb                      # restore tap to latest
  brew pin apm
  ```
- Once fixed upstream (track #2443 / #2446 / #2492): `brew unpin apm && brew upgrade apm`

## Installation Script Architecture
- `install`: Bootstrap script that handles system preparation (Xcode CLT, system updates) before repo cloning
- `setup.sh`: Main installer that handles Nix installation, Homebrew, and Darwin configuration
- `scripts/enable-module.sh`: Interactive module management with validation
- `scripts/lib.sh`: Shared utilities for logging, macOS checks, and constants
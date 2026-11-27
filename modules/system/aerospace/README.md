# AeroSpace

When den is enabled, the generated config runs `desk follow` on each workspace
change. The hook uses `programs.den.package` from Home Manager, so it points at
that package's absolute Nix store path and respects package overrides. With den
disabled or absent, the hook is omitted.

`aerospace.toml` is a template. Home Manager prepends the hook and manages the
rendered file; source edits require a Nix apply rather than taking effect
immediately on save. Prepending keeps the hook a top-level key whatever tables
the template declares, so don't define `exec-on-workspace-change` in the
template.

The existing rule that makes HUD windows floating remains. Automatic follow
moves only floating windows whose bundle IDs are declared under `global_floating`
in the private `~/Den/config.yaml`. Tiled windows and undeclared floating windows
are unaffected by follow.

## Validation and reload

Run `just nix check` for flake checks and `just nix build` for a rootless system
build.

Home Manager's file `onChange` hook reloads a running AeroSpace after linking a
changed rendered config. It does not run when the content is unchanged or during
a dry-run. A stopped AeroSpace reads the latest config when it starts.

The file watcher is disabled because a Nix store symlink swap does not notify
it. If activation reports a reload failure or a missing `aerospace` CLI, run
`aerospace reload-config` in the graphical user session. Validate with
`just nix dry-run` from main before applying system changes.

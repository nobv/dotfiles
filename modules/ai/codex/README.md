# Codex plugin hook repair

Codex's plugin fingerprinting rejects symlinks created by dependency installers
inside claude-mem's `node_modules/.bin` directories. This command is a temporary
workaround for [openai/codex#56520](https://github.com/openai/codex/issues/56520).

From the dotfiles checkout, preview first, then apply:

```sh
just codex repair-hooks
just codex repair-hooks --apply
```

The command discovers all cached claude-mem versions under
`${CODEX_HOME:-$HOME/.codex}/plugins/cache/*/claude-mem/`. To select one explicitly:

```sh
just codex repair-hooks --plugin-root /path/to/claude-mem/version
```

Each supported symlink becomes an executable shell wrapper that calls the original
target with unchanged arguments. Targets remain untouched. All selected versions
are checked before repairs start; dangling, external, directory and unfamiliar
symlinks cause an error. Rerunning an already repaired cache makes no changes.

After applying, review and reapprove the plugin in Codex `/hooks` if requested.
The command does not edit approvals. Rerun after plugin updates or dependency
installs if the error returns; it is not run automatically during `just apply`.
No Nix activation is needed to use the command from this checkout.

Run the isolated regression checks with `just codex test`.

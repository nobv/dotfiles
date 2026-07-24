#!/bin/bash

# claude-plugin-sync.sh — declaratively reconcile Claude Code native plugins.
#
# Source of truth is ~/.claude/settings.json (or $CLAUDE_CONFIG_DIR):
#   - extraKnownMarketplaces -> `claude plugin marketplace add <repo>`
#   - enabledPlugins         -> `claude plugin install <plugin@marketplace>`
#
# Runs for the primary config dir and for every profile under
# ~/.config/claude/profiles/* — each profile is an isolated CLAUDE_CONFIG_DIR
# with its own plugins/ tree (see modules/ai/claude-code), so plugins installed
# for the primary dir are invisible there.
#
# Idempotent: marketplaces already in known_marketplaces.json and plugins
# already in installed_plugins.json are skipped. Entries present in a config dir
# but absent from settings.json are left alone — this only ever adds, so a
# profile keeps plugins installed ad hoc under it.
#
# Role split with apm (modules/ai/apm): apm owns skills and MCP servers — its
# sweet spot, with lockfile/version pinning. This script owns native Claude Code
# plugins via the `claude plugin` CLI, which apm cannot drive and whose flat
# deploy breaks plugins that depend on their native directory layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

PRIMARY_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
PRIMARY_SETTINGS="${PRIMARY_DIR}/settings.json"
PROFILES_ROOT="${XDG_CONFIG_HOME:-${HOME}/.config}/claude/profiles"

command -v claude >/dev/null 2>&1 || { log_error "claude CLI not found in PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { log_error "jq not found in PATH"; exit 1; }
[ -f "${PRIMARY_SETTINGS}" ] || { log_error "settings.json not found: ${PRIMARY_SETTINGS}"; exit 1; }

# Returns success if a JSON object file has the given top-level key.
json_has_key() {
    local file="$1" path="$2" key="$3"
    [ -f "${file}" ] || return 1
    jq -e --arg k "${key}" "${path} | has(\$k)" "${file}" >/dev/null 2>&1
}

# Reconcile one config dir against one settings.json. CLAUDE_CONFIG_DIR is set
# per command so the `claude plugin` CLI reads and writes that dir's plugins/
# tree instead of the primary one.
sync_config_dir() {
    local config_dir="$1" settings="$2"
    local known_marketplaces="${config_dir}/plugins/known_marketplaces.json"
    local installed_plugins="${config_dir}/plugins/installed_plugins.json"

    # 1. Register marketplaces declared in extraKnownMarketplaces.
    #    Built-in marketplaces (e.g. claude-plugins-official) are auto-known and
    #    simply never appear here, so they are left untouched.
    log_info "  Reconciling marketplaces from extraKnownMarketplaces..."
    while IFS=$'\t' read -r name repo; do
        [ -n "${name}" ] || continue
        if json_has_key "${known_marketplaces}" "." "${name}"; then
            log_info "    marketplace already registered: ${name}"
        elif [ -z "${repo}" ] || [ "${repo}" = "null" ]; then
            log_warning "    ${name}: no .source.repo in settings.json, skipping"
        else
            log_info "    adding marketplace: ${name} (${repo})"
            CLAUDE_CONFIG_DIR="${config_dir}" claude plugin marketplace add "${repo}"
        fi
    done < <(jq -r '.extraKnownMarketplaces // {} | to_entries[] | "\(.key)\t\(.value.source.repo // "")"' "${settings}")

    # 2. Install plugins declared in enabledPlugins (form: plugin@marketplace).
    log_info "  Reconciling plugins from enabledPlugins..."
    while read -r entry; do
        [ -n "${entry}" ] || continue
        if json_has_key "${installed_plugins}" ".plugins" "${entry}"; then
            log_info "    plugin already installed: ${entry}"
        else
            log_info "    installing plugin: ${entry}"
            if ! CLAUDE_CONFIG_DIR="${config_dir}" claude plugin install "${entry}"; then
                log_warning "    failed to install ${entry} (marketplace registered? plugin name correct?)"
            fi
        fi
    done < <(jq -r '.enabledPlugins // {} | keys[]' "${settings}")
}

log_info "Config dir: ${PRIMARY_DIR}"
sync_config_dir "${PRIMARY_DIR}" "${PRIMARY_SETTINGS}"

# Profiles share the declarations but not the plugins/ tree. A profile whose
# settings.json is missing (its symlink lost to an atomic rewrite before the
# profile was declared in Nix) falls back to the primary settings — the same
# file the symlink resolves to.
if [ -d "${PROFILES_ROOT}" ]; then
    for profile_dir in "${PROFILES_ROOT}"/*/; do
        profile_dir="${profile_dir%/}"
        [ -d "${profile_dir}" ] || continue
        # Skip when CLAUDE_CONFIG_DIR already pointed at this profile.
        [ "${profile_dir}" = "${PRIMARY_DIR}" ] && continue

        settings="${profile_dir}/settings.json"
        if [ -f "${settings}" ]; then
            log_info "Profile: $(basename "${profile_dir}")"
        else
            settings="${PRIMARY_SETTINGS}"
            log_info "Profile: $(basename "${profile_dir}") (no settings.json, using primary)"
        fi
        sync_config_dir "${profile_dir}" "${settings}"
    done
fi

log_success "Plugin sync complete. Restart Claude Code to load newly installed plugins."

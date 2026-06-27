#!/bin/bash

# claude-plugin-sync.sh — declaratively reconcile Claude Code native plugins.
#
# Source of truth is ~/.claude/settings.json (or $CLAUDE_CONFIG_DIR):
#   - extraKnownMarketplaces -> `claude plugin marketplace add <repo>`
#   - enabledPlugins         -> `claude plugin install <plugin@marketplace>`
#
# Idempotent: marketplaces already in known_marketplaces.json and plugins
# already in installed_plugins.json are skipped.
#
# Role split with apm (modules/ai/apm): apm owns skills and MCP servers — its
# sweet spot, with lockfile/version pinning. This script owns native Claude Code
# plugins via the `claude plugin` CLI, which apm cannot drive and whose flat
# deploy breaks plugins that depend on their native directory layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
SETTINGS="${CONFIG_DIR}/settings.json"
KNOWN_MARKETPLACES="${CONFIG_DIR}/plugins/known_marketplaces.json"
INSTALLED_PLUGINS="${CONFIG_DIR}/plugins/installed_plugins.json"

command -v claude >/dev/null 2>&1 || { log_error "claude CLI not found in PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { log_error "jq not found in PATH"; exit 1; }
[ -f "${SETTINGS}" ] || { log_error "settings.json not found: ${SETTINGS}"; exit 1; }

# Returns success if a JSON object file has the given top-level key.
json_has_key() {
    local file="$1" path="$2" key="$3"
    [ -f "${file}" ] || return 1
    jq -e --arg k "${key}" "${path} | has(\$k)" "${file}" >/dev/null 2>&1
}

# 1. Register marketplaces declared in extraKnownMarketplaces.
#    Built-in marketplaces (e.g. claude-plugins-official) are auto-known and
#    simply never appear here, so they are left untouched.
log_info "Reconciling marketplaces from extraKnownMarketplaces..."
while IFS=$'\t' read -r name repo; do
    [ -n "${name}" ] || continue
    if json_has_key "${KNOWN_MARKETPLACES}" "." "${name}"; then
        log_info "  marketplace already registered: ${name}"
    elif [ -z "${repo}" ] || [ "${repo}" = "null" ]; then
        log_warning "  ${name}: no .source.repo in settings.json, skipping"
    else
        log_info "  adding marketplace: ${name} (${repo})"
        claude plugin marketplace add "${repo}"
    fi
done < <(jq -r '.extraKnownMarketplaces // {} | to_entries[] | "\(.key)\t\(.value.source.repo // "")"' "${SETTINGS}")

# 2. Install plugins declared in enabledPlugins (form: plugin@marketplace).
log_info "Reconciling plugins from enabledPlugins..."
while read -r entry; do
    [ -n "${entry}" ] || continue
    if json_has_key "${INSTALLED_PLUGINS}" ".plugins" "${entry}"; then
        log_info "  plugin already installed: ${entry}"
    else
        log_info "  installing plugin: ${entry}"
        if ! claude plugin install "${entry}"; then
            log_warning "  failed to install ${entry} (marketplace registered? plugin name correct?)"
        fi
    fi
done < <(jq -r '.enabledPlugins // {} | keys[]' "${SETTINGS}")

log_success "Plugin sync complete. Restart Claude Code to load newly installed plugins."

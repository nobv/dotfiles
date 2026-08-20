#!/bin/bash

# alfred-workflow-sync.sh — install the Alfred workflows this machine should have.
#
# Why a manifest instead of tracking the workflows themselves: the preferences
# bundle lives in this repo, but `Alfred.alfredpreferences/workflows/` is
# gitignored (see modules/productivity/alfred/.gitignore). Those folders belong
# to their upstreams — they auto-update in place — and a workflow folder is also
# where API keys and machine-specific configuration end up, which this public
# repo must never hold. So the repo records *which* workflows belong here, not
# what is inside them.
#
# What this syncs is therefore the set of workflows, not their settings: keyword
# and hotkey edits live in a workflow's own info.plist and Configure Workflow
# values in its prefs.plist, and both stay wherever Alfred wrote them.
#
# Two sources, because the workflows have two origins:
#   - Gallery workflows come from https://alfred.app/workflows/<author>/<slug>/download/,
#     which redirects to a pinned commit in alfredapp/gallery-workflows.
#   - The self-made desk switcher is copied out of the den checkout's alfred/
#     directory. den builds the same content into alfred/dist, but that path is
#     gitignored there, so a fresh clone only has the source directory.
#
# Idempotent, and a no-op run makes no network requests at all: the manifest
# carries each bundle id, so "already installed" is decided locally.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST="${REPO_DIR}/modules/productivity/alfred/workflows.txt"
PLIST_BUDDY="/usr/libexec/PlistBuddy"
GALLERY_BASE="https://alfred.app/workflows"

# Where the self-made workflow's source lives inside a den checkout, and the
# label used for it in messages — its bundle id names a private domain, so it is
# never printed and never written down here.
DEN_WORKFLOW_SUBDIR="alfred"
DEN_WORKFLOW_LABEL="desk switcher"

check_macos
[ -f "${MANIFEST}" ] || { log_error "manifest not found: ${MANIFEST}"; exit 1; }

WORK_TMP="$(mktemp -d "${TMPDIR:-/tmp}/alfred-workflow-sync.XXXXXX")"
trap 'rm -rf "${WORK_TMP}"' EXIT

# Alfred keeps the absolute path of the active preferences folder in prefs.json;
# nothing in this repo is a symlink to it, so that file is the only honest
# answer to "where do workflows go on this machine". ALFRED_WORKFLOWS_DIR
# overrides it, which is how this script is tested without touching live Alfred.
resolve_workflows_dir() {
    if [ -n "${ALFRED_WORKFLOWS_DIR:-}" ]; then
        printf '%s' "${ALFRED_WORKFLOWS_DIR}"
        return 0
    fi

    local prefs_json="${HOME}/Library/Application Support/Alfred/prefs.json"
    [ -f "${prefs_json}" ] || return 1
    command -v jq >/dev/null 2>&1 || { log_error "jq not found in PATH" >&2; return 1; }

    local current
    current="$(jq -r '.current // empty' "${prefs_json}")"
    [ -n "${current}" ] || return 1
    [ -d "${current}" ] || return 1

    printf '%s' "${current}/workflows"
}

bundle_id_of() {
    "${PLIST_BUDDY}" -c 'Print :bundleid' "$1/info.plist" 2>/dev/null || true
}

installed_bundle_ids() {
    local dir
    for dir in "${WORKFLOWS_DIR}"/*/; do
        [ -f "${dir}info.plist" ] || continue
        bundle_id_of "${dir%/}"
    done
}

is_installed() {
    printf '%s\n' "${INSTALLED_IDS}" | grep -qxF "$1"
}

# Move a staged folder into place, but only once it looks like the workflow the
# manifest asked for — this is what catches an HTML error page served instead of
# an archive, or an upstream slug that now points at something else. The move is
# the last step so Alfred never scans a half-written folder.
place_workflow() {
    local staged="$1" expected="$2" label="$3"

    if [ ! -f "${staged}/info.plist" ]; then
        log_error "${label}: no info.plist in the bundle"
        return 1
    fi

    local found
    found="$(bundle_id_of "${staged}")"
    if [ "${found}" != "${expected}" ]; then
        log_error "${label}: bundle id mismatch — the source is not the expected workflow"
        return 1
    fi

    mv "${staged}" "${WORKFLOWS_DIR}/user.workflow.$(uuidgen)"
    log_success "${label}: installed"
}

install_gallery_workflow() {
    local bundleid="$1" slug="$2"
    local archive="${WORK_TMP}/${bundleid}.alfredworkflow"
    local staged="${WORK_TMP}/${bundleid}"

    log_info "  ${slug}: downloading..."
    if ! curl -fsSL "${GALLERY_BASE}/${slug}/download/" -o "${archive}"; then
        log_error "${slug}: download failed"
        return 1
    fi

    mkdir -p "${staged}"
    if ! unzip -oq "${archive}" -d "${staged}"; then
        log_error "${slug}: not a readable .alfredworkflow archive"
        return 1
    fi

    place_workflow "${staged}" "${bundleid}" "${slug}"
}

# den lives outside this repo and moves around, so let den.just answer where it
# is rather than duplicating its lookup. DEN_PATH wins, as it does there.
den_checkout() {
    if [ -n "${DEN_PATH:-}" ]; then
        printf '%s' "${DEN_PATH}"
        return 0
    fi
    command -v just >/dev/null 2>&1 || return 1
    (cd "${REPO_DIR}" && just den path 2>/dev/null) || return 1
}

# Copy the workflow out of den rather than building it: `just den
# build-alfred-workflow` would write into that checkout, and the zip it produces
# holds exactly these files anyway.
install_den_workflow() {
    local den src bundleid staged entry
    den="$(den_checkout || true)"
    src="${den:+${den}/${DEN_WORKFLOW_SUBDIR}}"

    if [ -z "${den}" ] || [ ! -f "${src}/info.plist" ]; then
        log_warning "den checkout not found — skipping the ${DEN_WORKFLOW_LABEL} (set DEN_PATH to install it)"
        return 0
    fi

    bundleid="$(bundle_id_of "${src}")"
    if [ -z "${bundleid}" ]; then
        log_error "${DEN_WORKFLOW_LABEL}: den's info.plist has no bundle id"
        return 1
    fi

    DEN_BUNDLE_ID="${bundleid}"
    if is_installed "${bundleid}"; then
        log_info "  ${DEN_WORKFLOW_LABEL}: already installed"
        return 0
    fi

    staged="${WORK_TMP}/den-workflow"
    mkdir -p "${staged}"
    for entry in "${src}"/*; do
        # dist/ is den's build output, not part of the workflow
        [ "$(basename "${entry}")" = "dist" ] && continue
        cp -Rp "${entry}" "${staged}/"
    done

    place_workflow "${staged}" "${bundleid}" "${DEN_WORKFLOW_LABEL}" || return 1
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
}

# A workflow installed by hand is invisible to every other machine until it is
# written down, which is the exact problem this script exists to fix. Report by
# name, never by bundle id, so a private one stays private in the output too.
report_unmanaged() {
    local dir bundleid name
    for dir in "${WORKFLOWS_DIR}"/*/; do
        [ -f "${dir}info.plist" ] || continue
        bundleid="$(bundle_id_of "${dir%/}")"
        [ -n "${bundleid}" ] || continue
        if printf '%s\n' "${MANAGED_IDS}" | grep -qxF "${bundleid}"; then
            continue
        fi
        name="$("${PLIST_BUDDY}" -c 'Print :name' "${dir}info.plist" 2>/dev/null || basename "${dir}")"
        log_warning "not in the manifest: ${name} — add it to workflows.txt to have it follow you"
    done
}

WORKFLOWS_DIR="$(resolve_workflows_dir)" || {
    log_info "Alfred is not set up on this machine — nothing to sync"
    exit 0
}
mkdir -p "${WORKFLOWS_DIR}"
log_info "Syncing Alfred workflows into ${WORKFLOWS_DIR}"

INSTALLED_IDS="$(installed_bundle_ids)"
INSTALLED_COUNT=0
DEN_BUNDLE_ID=""
FAILED=0
MANAGED_IDS=""

while read -r bundleid slug _rest; do
    case "${bundleid}" in ''|\#*) continue ;; esac
    if [ -z "${slug}" ]; then
        log_error "malformed manifest line: ${bundleid}"
        FAILED=1
        continue
    fi

    MANAGED_IDS="${MANAGED_IDS}${bundleid}"$'\n'

    if is_installed "${bundleid}"; then
        log_info "  ${slug}: already installed"
        continue
    fi

    if install_gallery_workflow "${bundleid}" "${slug}"; then
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        FAILED=1
    fi
done < "${MANIFEST}"

install_den_workflow || FAILED=1
MANAGED_IDS="${MANAGED_IDS}${DEN_BUNDLE_ID}"

report_unmanaged

if [ "${INSTALLED_COUNT}" -gt 0 ]; then
    log_success "Installed ${INSTALLED_COUNT} workflow(s)"
    log_info "Restart Alfred if they do not show up in Preferences"
else
    log_success "All manifest workflows are already installed"
fi

exit "${FAILED}"

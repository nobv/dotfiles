#!/bin/bash

# alfred-workflows.sh — keep the Alfred workflows on this machine and the
# manifest that describes them in step.
#
#   sync   install everything modules/productivity/alfred/workflows.txt lists
#          but this machine is missing
#   add    write workflows installed here but missing from the manifest into it
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
# `sync` is idempotent, and a no-op run makes no network requests at all: the
# manifest carries each bundle id, so "already installed" is decided locally.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST="${REPO_DIR}/modules/productivity/alfred/workflows.txt"
PLIST_BUDDY="/usr/libexec/PlistBuddy"
GALLERY_BASE="https://alfred.app/workflows"

# The Alfred Gallery workflow keeps a catalogue of every Gallery workflow —
# title plus its alfred.app URL — which is what lets `add` turn an installed
# workflow into a manifest line. Its own release is the fallback for a machine
# that has never run it.
GALLERY_CATALOGUE="${HOME}/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/com.alfredapp.vitor.alfredgallery/cache.json"
GALLERY_CATALOGUE_REPO="alfredapp/gallery-cache"

# Where the self-made workflow's source lives inside a den checkout, and the
# label used for it in messages — its bundle id names a private domain, so it is
# never printed and never written down here.
DEN_WORKFLOW_SUBDIR="alfred"
DEN_WORKFLOW_LABEL="desk switcher"

usage() {
    cat >&2 <<'USAGE'
usage: alfred-workflows.sh <command>

  sync   install the manifest's workflows that this machine is missing
  add    append workflows installed here but missing from the manifest
USAGE
    exit 2
}

need_jq() {
    command -v jq >/dev/null 2>&1 || { log_error "jq not found in PATH"; exit 1; }
}

# ---------------------------------------------------------------- workflows dir

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
    need_jq

    local current
    current="$(jq -r '.current // empty' "${prefs_json}")"
    [ -n "${current}" ] || return 1
    [ -d "${current}" ] || return 1

    printf '%s' "${current}/workflows"
}

require_workflows_dir() {
    WORKFLOWS_DIR="$(resolve_workflows_dir)" || {
        log_info "Alfred is not set up on this machine — nothing to do"
        exit 0
    }
    mkdir -p "${WORKFLOWS_DIR}"
}

# ------------------------------------------------------------------ plist reads

plist_value() {
    "${PLIST_BUDDY}" -c "Print :$2" "$1/info.plist" 2>/dev/null || true
}

installed_bundle_ids() {
    local dir
    for dir in "${WORKFLOWS_DIR}"/*/; do
        [ -f "${dir}info.plist" ] || continue
        plist_value "${dir%/}" bundleid
    done
}

manifest_bundle_ids() {
    local bundleid _rest
    while read -r bundleid _rest; do
        case "${bundleid}" in ''|\#*) continue ;; esac
        printf '%s\n' "${bundleid}"
    done < "${MANIFEST}"
}

in_list() {
    printf '%s\n' "$2" | grep -qxF "$1"
}

# --------------------------------------------------------------------- den

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

# Path to den's workflow source, empty when there is no usable checkout.
den_workflow_source() {
    local den
    den="$(den_checkout || true)"
    [ -n "${den}" ] || return 0
    [ -f "${den}/${DEN_WORKFLOW_SUBDIR}/info.plist" ] || return 0
    printf '%s' "${den}/${DEN_WORKFLOW_SUBDIR}"
}

# ------------------------------------------------------------------- installing

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
    found="$(plist_value "${staged}" bundleid)"
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

# Copy the workflow out of den rather than building it: `just den
# build-alfred-workflow` would write into that checkout, and the zip it produces
# holds exactly these files anyway.
install_den_workflow() {
    local src bundleid staged entry
    src="$(den_workflow_source)"

    if [ -z "${src}" ]; then
        log_warning "den checkout not found — skipping the ${DEN_WORKFLOW_LABEL} (set DEN_PATH to install it)"
        return 0
    fi

    bundleid="$(plist_value "${src}" bundleid)"
    if [ -z "${bundleid}" ]; then
        log_error "${DEN_WORKFLOW_LABEL}: den's info.plist has no bundle id"
        return 1
    fi

    if in_list "${bundleid}" "${INSTALLED_IDS}"; then
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

# ------------------------------------------------------------------------ sync

cmd_sync() {
    require_workflows_dir
    log_info "Syncing Alfred workflows into ${WORKFLOWS_DIR}"

    INSTALLED_IDS="$(installed_bundle_ids)"
    INSTALLED_COUNT=0
    local failed=0 bundleid slug _rest managed
    managed=""

    while read -r bundleid slug _rest; do
        case "${bundleid}" in ''|\#*) continue ;; esac
        if [ -z "${slug}" ]; then
            log_error "malformed manifest line: ${bundleid}"
            failed=1
            continue
        fi

        managed="${managed}${bundleid}"$'\n'

        if in_list "${bundleid}" "${INSTALLED_IDS}"; then
            log_info "  ${slug}: already installed"
            continue
        fi

        if install_gallery_workflow "${bundleid}" "${slug}"; then
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        else
            failed=1
        fi
    done < "${MANIFEST}"

    install_den_workflow || failed=1

    local den_src
    den_src="$(den_workflow_source)"
    [ -n "${den_src}" ] && managed="${managed}$(plist_value "${den_src}" bundleid)"$'\n'

    # A workflow installed by hand is invisible to every other machine until it
    # is written down, which is the exact problem this script exists to fix.
    local dir name
    for dir in "${WORKFLOWS_DIR}"/*/; do
        [ -f "${dir}info.plist" ] || continue
        bundleid="$(plist_value "${dir%/}" bundleid)"
        [ -n "${bundleid}" ] || continue
        in_list "${bundleid}" "${managed}" && continue
        # By name, never by bundle id, so a private one stays private in the output
        name="$(plist_value "${dir%/}" name)"
        log_warning "not in the manifest: ${name:-${dir}} — run \`just alfred add\` to record it"
    done

    if [ "${INSTALLED_COUNT}" -gt 0 ]; then
        log_success "Installed ${INSTALLED_COUNT} workflow(s)"
        log_info "Restart Alfred if they do not show up in Preferences"
    elif [ "${failed}" -eq 0 ]; then
        log_success "All manifest workflows are already installed"
    fi

    # Last, so a failed run does not end on a success line
    if [ "${failed}" -ne 0 ]; then
        log_error "Some workflows could not be installed — see the errors above"
    fi

    return "${failed}"
}

# ------------------------------------------------------------------------- add

# The catalogue the local Alfred Gallery workflow caches is preferred: it is
# already there and costs nothing. Its 24h TTL means a workflow published very
# recently can be missing from it, so an unresolved name falls back to the
# published catalogue once before being reported as unknown.
ensure_catalogue() {
    [ -n "${CATALOGUE_FILE}" ] && return 0
    if [ -f "${GALLERY_CATALOGUE}" ]; then
        CATALOGUE_FILE="${GALLERY_CATALOGUE}"
        return 0
    fi
    refresh_catalogue
}

refresh_catalogue() {
    [ "${CATALOGUE_REFRESHED}" = "1" ] && return 0

    local api="https://api.github.com/repos/${GALLERY_CATALOGUE_REPO}/releases/latest"
    local url
    log_info "Fetching the Alfred Gallery catalogue..."
    if command -v gh >/dev/null 2>&1; then
        url="$(gh api "repos/${GALLERY_CATALOGUE_REPO}/releases/latest" \
            --jq '.assets[] | select(.name == "data.tgz") | .browser_download_url' 2>/dev/null || true)"
    else
        url="$(curl -fsSL "${api}" | jq -r '.assets[] | select(.name == "data.tgz") | .browser_download_url')"
    fi
    if [ -z "${url}" ]; then
        log_error "could not locate the catalogue release asset"
        return 1
    fi

    curl -fsSL "${url}" -o "${WORK_TMP}/data.tgz" || { log_error "catalogue download failed"; return 1; }
    tar -xzf "${WORK_TMP}/data.tgz" -C "${WORK_TMP}" cache.json || { log_error "catalogue archive has no cache.json"; return 1; }
    CATALOGUE_FILE="${WORK_TMP}/cache.json"
    CATALOGUE_REFRESHED=1
}

# Print every gallery URL whose entry carries this exact title. Zero lines means
# unknown, more than one means ambiguous — both are the caller's problem, since
# guessing would write the wrong workflow into the manifest. Logs nothing: it
# runs inside a command substitution, where a log line would become the result.
catalogue_lookup() {
    jq -r --arg t "$1" '.items[] | select(.title == $t) | .arg' "${CATALOGUE_FILE}"
}

# https://alfred.app/workflows/<author>/<slug>/ -> <author>/<slug>
slug_from_url() {
    printf '%s' "${1#"${GALLERY_BASE}"/}" | sed 's|/*$||'
}

manifest_append() {
    local bundleid="$1" slug="$2"
    # Keep the manifest's two columns lined up, unless the id is too long to
    if [ "${#bundleid}" -lt 34 ]; then
        printf '%-35s%s\n' "${bundleid}" "${slug}" >> "${MANIFEST}"
    else
        printf '%s  %s\n' "${bundleid}" "${slug}" >> "${MANIFEST}"
    fi
}

cmd_add() {
    require_workflows_dir
    need_jq

    local managed den_src den_id="" dir bundleid name
    managed="$(manifest_bundle_ids)"
    den_src="$(den_workflow_source)"
    [ -n "${den_src}" ] && den_id="$(plist_value "${den_src}" bundleid)"

    # Collect first, resolve second, so the catalogue is consulted once and the
    # "nothing to record" case never touches it. Entries are appended as they
    # resolve: a name the catalogue cannot settle fails the run without holding
    # back the ones it could.
    local -a pending_ids=() pending_names=()
    for dir in "${WORKFLOWS_DIR}"/*/; do
        [ -f "${dir}info.plist" ] || continue
        bundleid="$(plist_value "${dir%/}" bundleid)"
        [ -n "${bundleid}" ] || continue
        in_list "${bundleid}" "${managed}" && continue
        if [ -n "${den_id}" ] && [ "${bundleid}" = "${den_id}" ]; then
            log_info "  ${DEN_WORKFLOW_LABEL}: installed from den, not a manifest entry"
            continue
        fi
        name="$(plist_value "${dir%/}" name)"
        pending_ids+=("${bundleid}")
        pending_names+=("${name:-${dir}}")
    done

    if [ "${#pending_ids[@]}" -eq 0 ]; then
        log_success "The manifest already lists every workflow installed here"
        return 0
    fi

    ensure_catalogue || { log_error "the Alfred Gallery catalogue is unavailable — add the entries by hand"; return 1; }

    local i added=0 failed=0 matches count url
    for i in "${!pending_ids[@]}"; do
        name="${pending_names[${i}]}"
        bundleid="${pending_ids[${i}]}"

        matches="$(catalogue_lookup "${name}" || true)"
        # A miss against the cached catalogue may just be a stale cache
        if [ -z "${matches}" ] && [ "${CATALOGUE_REFRESHED}" != "1" ]; then
            refresh_catalogue && matches="$(catalogue_lookup "${name}" || true)"
        fi

        count="$(printf '%s' "${matches}" | grep -c . || true)"
        if [ "${count}" -eq 0 ]; then
            log_warning "${name}: not in the Alfred Gallery — install it from its own source and leave it out of the manifest"
            continue
        fi
        if [ "${count}" -gt 1 ]; then
            log_error "${name}: several Gallery workflows share this name — add the right one by hand:"
            while read -r url; do
                log_error "    $(slug_from_url "${url}")"
            done <<< "${matches}"
            failed=1
            continue
        fi

        manifest_append "${bundleid}" "$(slug_from_url "${matches}")"
        log_success "${name}: added as $(slug_from_url "${matches}")"
        added=$((added + 1))
    done

    if [ "${added}" -gt 0 ]; then
        log_success "Recorded ${added} workflow(s) in $(basename "${MANIFEST}")"
        log_info "Commit the change so the other machines pick it up"
    fi

    return "${failed}"
}

# ---------------------------------------------------------------------- dispatch

check_macos
[ -f "${MANIFEST}" ] || { log_error "manifest not found: ${MANIFEST}"; exit 1; }

WORK_TMP="$(mktemp -d "${TMPDIR:-/tmp}/alfred-workflows.XXXXXX")"
trap 'rm -rf "${WORK_TMP}"' EXIT
CATALOGUE_REFRESHED=0
CATALOGUE_FILE=""

case "${1:-}" in
    sync) cmd_sync ;;
    add) cmd_add ;;
    *) usage ;;
esac

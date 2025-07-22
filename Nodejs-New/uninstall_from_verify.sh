#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail
###########################################################
echo "-------------------Starting Uninstall_from_Verify.sh Script----------------------------"
source ./variables_functions.sh
source ./verify.sh

uninstall_from_verify() {

    ACTION_PERFORMED="Uninstall_from_Verify"
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"
    log "Starting ${ACTION_PERFORMED} ${SOFTWARENAME} Function"

    log "Running embedded verification to refresh candidate list..."
    verify

    latest_log=$(ls -t node-*-Verify-*.log 2>/dev/null | head -n1)
    if [[ -z "$latest_log" ]]; then
        log "No verify log file found. Cannot proceed with uninstall."
        return 1
    fi

    log "Using verify log file: $latest_log"

    mapfile -t targets < <(grep 'REMOVAL CANDIDATE' "$latest_log" | awk -F': ' '{print $2}' | awk '{print $1}')

    if [[ ${#targets[@]} -eq 0 ]]; then
        log "No removal candidates found."
        return 0
    fi

    log "Starting removal of candidates..."

    for path in "${targets[@]}"; do
        if [[ -L "$path" ]]; then
            log "Removing symlink: $path"
            rm -f "$path"
        elif [[ -f "$path" ]]; then
            log "Removing file: $path"
            rm -f "$path"
        else
            log "Path not found or already removed: $path"
        fi
    done

    log "Uninstall from verify completed."

    log "Re-running Verify to confirm final Node.js state..."
    verify
}

# Run only if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    uninstall_from_verify
fi
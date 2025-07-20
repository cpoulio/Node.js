#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail
################################################################################
echo "-------------------- Starting Uninstall_from_Verify.sh Script --------------------"
################################################################################

source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
source ./verify.sh && echo 'Sourced: verify.sh'
echo "Starting Uninstall_from_Verify Script"
ensure_root "$@"

uninstall_from_verify() {
    log "Starting Uninstall from Verify ${SOFTWARENAME} function"
    ACTION_PERFORMED='Starting Uninstall from Verify'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    # Run verify to ensure log is up to date
    verify

    # Parse the log for found Node.js, npm, npx executables, but skip vital OS path warnings.
    local vital_bins=()
    local found_bins=()
    while IFS= read -r line; do
        # Skip any WARNING lines for vital OS path
        if [[ $line =~ ^WARNING\ Found\ (node|npm|npx)\ in\ vital\ OS\ path:\ (.*)\ \(version:\ .*\)$ ]]; then
            vital_bins+=("${BASH_REMATCH[2]}")
        fi

        # Example: Found node /usr/local/bin/node (version: 20.19.3)
        if [[ $line =~ ^Found\ (node|npm|npx)\ (.*)\ \(version:\ .*\)$ ]]; then
            bin_bins=("${BASH_REMATCH[2]}")
            found_bins+=("${bin_bins[@]}")
        fi
    done < "${LOGDIR}/${LOG_FILE}"

    # Remove each found binary, but skip and that are in vital=
    for bin in "${found_bins[@]}"; do
        skip=0
        for vital in "${vital_bins[@]}"; do
            if [[ "$bin" == "$vital" ]]; then
                echo "Skipping vital OS binary: $bin"
                skip=1
                break
            fi
        done
        if [[ $skip -eq 0 && -e "$bin" ]]; then
            echo "Removing $bin"
            rm -f "$bin"
        fi
    done

    # Remove symlinks for node, npm, npx in common bin dirs (these are not flagged as vital in verify.sh)
    for dir in /usr/local/bin /usr/bin /bin /usr/sbin /sbin; do
        for bin in node npm npx; do
            if [[ -L "$dir/$bin" ]]; then
                echo "Removing symlink $dir/$bin..."
                sudo rm -f "$dir/$bin"
            fi
        done
    done

    # Optionally, remove Node.js directories from PATH (user must update shell config manually)
    echo "Uninstallation from verify complete. Please check your PATH and running processes."
}

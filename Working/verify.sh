#!/bin/bash
shopt -s extglob
#set -x
set -euo pipefail
# This script performs a comprehensive audit and validation of Node.js installations on the system.
#
# Key Objectives:
# - Discover all Node.js, npm, and npx binaries across the filesystem.
# - Verify the integrity and functionality of the intended Node.js installation.
# - Identify any other Node.js installations that may conflict or cause confusion.
# - Examine user PATH variables and system symlinks for correct Node.js configuration.
# - Detect Node.js binaries in critical operating system paths.
# - List all currently running Node.js processes.
#
# Purpose: To provide a complete Node.js inventory, validate deployments,
#          prevent version conflicts, and ensure safe system operations.
#
# Comprehensive Node.js Audit Script

# Source your variables and functions file—adjust the path if needed

verify() {
    ACTION_PERFORMED='Verify'
    source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
    LOG_FILE="${ACTION_PERFORMED}.log"

    

    echo "-------------------Starting Verify.sh Script $(date '+%Y-%m-%d-%H-%M-%S')----------------------------" 2>&1 | tee -a "$(get_log_file_path)"
    log "Starting Verify ${SOFTWARENAME} Function"

    echo "----------- NodeJS Audit & Candidate Report -----------" 2>&1 | tee -a "$(get_log_file_path)"
    echo "REMINDER: Review results carefully before deleting anything." 2>&1 | tee -a "$(get_log_file_path)"

    declare -a search_paths=("/") 
    node_binaries=("node" "npm" "npx")

    for binary in "${node_binaries[@]}"; do
        echo "----- [$binary Binaries] -----" 2>&1 | tee -a "$(get_log_file_path)"

        while IFS= read -r bin_path; do
            if [[ "$bin_path" =~ $EXCLUSION_PATTERN ]]; then
                status="DO NOT TOUCH"
            else
                status="REMOVAL CANDIDATE"
            fi
            version=$("$bin_path" -v 2>/dev/null || echo "N/A")
            echo "$status: $bin_path (version: $version)" 2>&1 | tee -a "$(get_log_file_path)"
        done < <(find "${search_paths[@]}" -type f -name "$binary" 2>/dev/null)
    done

    echo "----- [Symlinks for Node.js] -----" 2>&1 | tee -a "$(get_log_file_path)"
    while IFS= read -r symlink; do
        target=$(readlink -f "$symlink")
        if [[ "$target" =~ $EXCLUSION_PATTERN ]]; then
            status="DO NOT TOUCH SYMLINK"
        else
            status="REMOVAL CANDIDATE"
        fi
        echo "$status: $symlink -> $target" 2>&1 | tee -a "$(get_log_file_path)"
    done < <(find "${search_paths[@]}" -type l \( -name "node" -o -name "npm" -o -name "npx" \) 2>/dev/null)

    echo "----- [Running Node.js Processes] -----" 2>&1 | tee -a "$(get_log_file_path)"
    pgrep -a node | while read -r pid cmd; do
        echo "NODE PROCESS: $pid $cmd" 2>&1 | tee -a "$(get_log_file_path)"
    done

    echo "----- [End of Audit] -----" 2>&1 | tee -a "$(get_log_file_path)"
}

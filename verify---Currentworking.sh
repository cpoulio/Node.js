#!/bin/bash
#
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

shopt -s extglob
set -euo pipefail
##########################################################
echo "-------------------Starting Verify.sh Script----------------------------"
source ./variables_functions.sh

verify() {

    ACTION_PERFORMED='Verify'
    LOG_FILE="${ACTION_PERFORMED}-${DATE}.log"
    log "Starting Verify ${SOFTWARENAME} Function"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ---------------------- Starting NodeJS System Audit & Candidate Script ----------------------" | tee -a "$LOG_FILE"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - REMINDER: Backup your data before deleting any Node.js binaries or symlinks." | tee -a "$LOG_FILE"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ---------------------------" | tee -a "$LOG_FILE"

    # Candidate Counters
    node_removal_count=0
    npm_removal_count=0
    npx_removal_count=0
    symlink_removal_count=0

    # ----- [Node.js Binaries by Location] -----
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ----- [Node.js Binaries by Location] -----" | tee -a "$LOG_FILE"
    node_found=0
    removal_candidates=0

    while IFS= read -r node_path; do
        if [[ "$node_path" == *"/usr/local/lib/nodejs/"* ]]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - REMOVAL CANDIDATE: $node_path (version: $("$node_path" -v 2>/dev/null || echo N/A))" | tee -a "$LOG_FILE"
            removal_candidates=$((removal_candidates+1))
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S") - DO NOT TOUCH: $node_path (version: $("$node_path" -v 2>/dev/null || echo N/A))" | tee -a "$LOG_FILE"
        fi
        node_found=1
    done < <(find /usr/local/lib/nodejs /opt/actions-runners /root/.cache /usr/local/bin -type f -name 'node' 2>/dev/null)

    if [[ "$node_found" -eq 0 ]]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - No Node.js binaries found." | tee -a "$LOG_FILE"
    fi

    # ----- [npm Binaries by Location] -----
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ----- [npm Binaries by Location] -----" | tee -a "$LOG_FILE"
    npm_found=0
    while IFS= read -r npm_path; do
        if [[ "$npm_path" == *"/usr/local/lib/nodejs/"* ]]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - REMOVAL CANDIDATE: $npm_path (version: N/A)" | tee -a "$LOG_FILE"
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S") - DO NOT TOUCH: $npm_path (version: N/A)" | tee -a "$LOG_FILE"
        fi
        npm_found=1
    done < <(find /usr/local/lib/nodejs /opt/actions-runners /root/.cache /usr/local/bin -type f -name 'npm' 2>/dev/null)

    if [[ "$npm_found" -eq 0 ]]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - No npm binaries found." | tee -a "$LOG_FILE"
    fi

    # ----- [npx Binaries by Location] -----
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ----- [npx Binaries by Location] -----" | tee -a "$LOG_FILE"
    npx_found=0
    while IFS= read -r npx_path; do
        if [[ "$npx_path" == *"/usr/local/lib/nodejs/"* ]]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - REMOVAL CANDIDATE: $npx_path (version: N/A)" | tee -a "$LOG_FILE"
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S") - DO NOT TOUCH: $npx_path (version: N/A)" | tee -a "$LOG_FILE"
        fi
        npx_found=1
    done < <(find /usr/local/lib/nodejs /opt/actions-runners /root/.cache /usr/local/bin -type f -name 'npx' 2>/dev/null)

    if [[ "$npx_found" -eq 0 ]]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - No npx binaries found." | tee -a "$LOG_FILE"
    fi

    # ----- [Symlinks in System Bins] -----
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ----- [Symlinks in System Bins] -----" | tee -a "$LOG_FILE"
    for bin in node npm npx; do
        for link in /usr/local/bin/$bin; do
            if [ -L "$link" ]; then
                target=$(readlink "$link")
                if [[ "$target" == *"/usr/local/lib/nodejs/"* ]]; then
                    echo "$(date +"%Y-%m-%d %H:%M:%S") - REMOVAL CANDIDATE SYMLINK: $link -> $target" | tee -a "$LOG_FILE"
                else
                    echo "$(date +"%Y-%m-%d %H:%M:%S") - DO NOT TOUCH SYMLINK: $link -> $target" | tee -a "$LOG_FILE"
                fi
            fi
        done
    done

    # ----- [Running Node.js Processes] -----
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ----- [Running Node.js Processes] -----" | tee -a "$LOG_FILE"
    pgrep -a node | while read -r pid cmd; do
        echo "$(date +"%Y-%m-%d %H:%M:%S") - NODE PROCESS: $pid $cmd" | tee -a "$LOG_FILE"
    done

    echo "$(date +"%Y-%m-%d %H:%M:%S") - ----- [End of Node.js System Audit & Candidate List] -----" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
    echo "See above and in $LOG_FILE for all Node.js locations and clear REMOVAL CANDIDATES."
    echo "Review before deleting! This script does NOT delete anything."
}

# Run only if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    verify
fi
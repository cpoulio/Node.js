#!/bin/bash
set -euo pipefail

# Source shared functions and verify function
source ./variables_functions.sh
source ./verify.sh

LOG_FILE="uninstall_from_verify.log"

uninstall_from_verify() {
    log "------------------- Starting Uninstall_from_Verify.sh Script -------------------" 2>&1 | tee -a "$(get_log_file_path)"
    log "Starting Uninstall_from_Verify NodeJS Function" 2>&1 | tee -a "$(get_log_file_path)"

    log "Running initial verify to build fresh log..." 2>&1 | tee -a "$(get_log_file_path)"
    verify

    VERIFY_LOG="/tmp/Verify.log"
    log "Resolved verify log path: $VERIFY_LOG" 2>&1 | tee -a "$(get_log_file_path)"

    # Count and list all REMOVAL CANDIDATE targets
    removal_targets=$(grep '^REMOVAL CANDIDATE:' "$VERIFY_LOG" || true)
    target_count=$(echo "$removal_targets" | grep -c '^REMOVAL CANDIDATE:' || true)
    log "Found $target_count removal targets" 2>&1 | tee -a "$(get_log_file_path)"
    echo "🔍 Total targets found: $target_count" 2>&1 | tee -a "$(get_log_file_path)"

    # Remove all REMOVAL CANDIDATE paths, forcibly
    echo "$removal_targets" | while IFS= read -r line; do
        target=$(echo "$line" | cut -d: -f2- | sed 's/ (version:.*//; s/^[ \t]*//; s/[ \t]*$//')
        if [[ -n "$target" ]]; then
            echo "Removing: $target" 2>&1 | tee -a "$(get_log_file_path)"
            if [[ "$target" == *"->"* ]]; then
                symlink=$(echo "$target" | awk -F'->' '{print $1}' | xargs)
                linktarget=$(echo "$target" | awk -F'->' '{print $2}' | xargs)
                rm -f "$symlink" 2>/dev/null && echo "✅ REMOVED symlink: $symlink" 2>&1 | tee -a "$(get_log_file_path)" || echo "❌ FAILED TO REMOVE symlink: $symlink" 2>&1 | tee -a "$(get_log_file_path)"
                if [[ -e "$linktarget" ]]; then
                    rm -f "$linktarget" 2>/dev/null && echo "✅ REMOVED link target: $linktarget" 2>&1 | tee -a "$(get_log_file_path)" || echo "❌ FAILED TO REMOVE link target: $linktarget" 2>&1 | tee -a "$(get_log_file_path)"
                fi
            else
                rm -f "$target" 2>/dev/null && echo "✅ REMOVED: $target" 2>&1 | tee -a "$(get_log_file_path)" || echo "❌ FAILED TO REMOVE: $target" 2>&1 | tee -a "$(get_log_file_path)"
            fi
        fi
    done

    # Clean NodeJS PATH entries from all profile files
    remove_node_bin_dir_from_profiles

    # Remove NodeJS install directories (aggressive cleanup)
    for dir in /usr/local/lib/nodejs/node-v*; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo "✅ REMOVED directory: $dir" 2>&1 | tee -a "$(get_log_file_path)"
        fi
    done

    log "Initial cleanup complete. Re-running verify to confirm final state..." 2>&1 | tee -a "$(get_log_file_path)"
    echo "🔁 Re-running verification to confirm cleanup..." 2>&1 | tee -a "$(get_log_file_path)"
    verify

    log "Uninstall_from_Verify process complete." 2>&1 | tee -a "$(get_log_file_path)"
    echo "✅ Finished Uninstall from Verify process"

    send_email || log "send_email function not found, skipping email."
}

# Only run if this script is called directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    uninstall_from_verify
fi

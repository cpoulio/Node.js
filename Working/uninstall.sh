#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail
################################################################################

uninstall() {

    ACTION_PERFORMED='Uninstall'
    source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
    source ./verify.sh && echo 'Sourced: verify.sh'
    LOG_FILE="${ACTION_PERFORMED}.log"

    log "------------------- Starting Uninstall.sh Script -------------------" 2>&1 | tee -a "$(get_log_file_path)"
    log "Starting Uninstall NodeJS Function" 2>&1 | tee -a "$(get_log_file_path)"

    log "Running initial verify to build fresh log..." 2>&1 | tee -a "$(get_log_file_path)"
    # Assuming verify is a function already sourced or available
    verify

    VERIFY_LOG="/tmp/Verify.log"
    log "Resolved verify log path: $VERIFY_LOG" 2>&1 | tee -a "$(get_log_file_path)"

    # Count and list all REMOVAL CANDIDATE targets
    removal_targets=$(grep '^REMOVAL CANDIDATE:' "$VERIFY_LOG" || true)
    target_count=$(echo "$removal_targets" | grep -c '^REMOVAL CANDIDATE:' || true)
    log "Found $target_count removal targets" 2>&1 | tee -a "$(get_log_file_path)"
    echo "🔍 Total targets found: $target_count" 2>&1 | tee -a "$(get_log_file_path)"

    # Remove all REMOVAL CANDIDATE paths, forcibly and safely (handles symlinks and link targets)
    echo "$removal_targets" | while IFS= read -r line; do
        target=$(echo "$line" | cut -d: -f2- | sed 's/ (version:.*//; s/^[ \t]*//; s/[ \t]*$//')
        if [[ -n "$target" ]]; then
            echo "Removing: $target" 2>&1 | tee -a "$(get_log_file_path)"
            if [[ "$target" == *"->"* ]]; then
                # Symlink format: /path/to/symlink -> /path/to/target
                symlink=$(echo "$target" | awk -F'->' '{print $1}' | xargs)
                linktarget=$(echo "$target" | awk -F'->' '{print $2}' | xargs)
                rm -f "$symlink" 2>/dev/null || true
                if [[ -L "$symlink" ]]; then
                    echo "❌ FAILED TO REMOVE symlink: $symlink" 2>&1 | tee -a "$(get_log_file_path)"
                else
                    echo "✅ REMOVED symlink: $symlink" 2>&1 | tee -a "$(get_log_file_path)"
                fi
                # Only remove the link target if it’s a file
                if [[ -f "$linktarget" ]]; then
                    rm -f "$linktarget" 2>/dev/null || true
                    if [[ -e "$linktarget" ]]; then
                        echo "❌ FAILED TO REMOVE link target: $linktarget" 2>&1 | tee -a "$(get_log_file_path)"
                    else
                        echo "✅ REMOVED link target: $linktarget" 2>&1 | tee -a "$(get_log_file_path)"
                    fi
                fi
            else
                # Plain file removal
                rm -f "$target" 2>/dev/null || true
                if [[ -e "$target" || -L "$target" ]]; then
                    echo "❌ FAILED TO REMOVE: $target" 2>&1 | tee -a "$(get_log_file_path)"
                else
                    echo "✅ REMOVED: $target" 2>&1 | tee -a "$(get_log_file_path)"
                fi
            fi
        fi
    done

    log "Initial cleanup complete. Re-running verify to confirm final state..." 2>&1 | tee -a "$(get_log_file_path)"
    echo "🔁 Re-running verification to confirm cleanup..." 2>&1 | tee -a "$(get_log_file_path)"
    verify

    log "Uninstall process complete." 2>&1 | tee -a "$(get_log_file_path)"
    echo "✅ Finished Uninstall process"

    #send_email || log "send_email function not found, skipping email."
}

# Only run if this script is called directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    uninstall
fi

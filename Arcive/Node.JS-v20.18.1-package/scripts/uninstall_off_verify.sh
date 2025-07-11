#!/bin/bash
# uninstall_off_verify.sh - Uninstall Node.js installations found by verify.sh

# Path to verify.sh (adjust if needed)
VERIFY_SCRIPT="$(dirname "$0")/verify.sh"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

uninstall_off_verify() {
    if [ ! -f "$VERIFY_SCRIPT" ]; then
        log "verify.sh not found at $VERIFY_SCRIPT. Aborting."
        exit 1
    fi
    log "Running verify.sh to find Node.js installations..."
    NODEJS_DIRS=$(bash "$VERIFY_SCRIPT")
    if [ -z "$NODEJS_DIRS" ]; then
        log "No Node.js installations found by verify.sh."
        return 0
    fi
    for DIR in $NODEJS_DIRS; do
        if [ -d "$DIR" ]; then
            log "Removing $DIR"
            rm -rf "$DIR"
        else
            log "$DIR does not exist or is not a directory. Skipping."
        fi
    done
    log "Uninstall off verify complete."
}

# Run the function if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    uninstall_off_verify
fi

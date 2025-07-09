#!/bin/bash
# verify.sh - Defines verify_nodejs function to check for installed Node.js versions, log, and email results

# This script does NOT source any other scripts. Sourcing is handled by main.sh.
# Only the function is defined here for reuse.

verify() {
    LOG_FILE="verify_nodejs.log"
    > "${LOGDIR}/${LOG_FILE}"
    log "Starting Node.js verification..."

    # 1. Node.js & NPM versions
    NODE_VERSION_OUTPUT="$(command -v node >/dev/null 2>&1 && node -v 2>/dev/null || echo "Not found")"
    NPM_VERSION_OUTPUT="$(command -v npm >/dev/null 2>&1 && npm -v 2>/dev/null || echo "Not found")"
    NPX_VERSION_OUTPUT="$(command -v npx >/dev/null 2>&1 && npx -v 2>/dev/null || echo "Not found")"
    log "Node.js version: $NODE_VERSION_OUTPUT"
    log "npm version: $NPM_VERSION_OUTPUT"
    log "npx version: $NPX_VERSION_OUTPUT"

    # 2. PATH contents
    log "PATH contents: $PATH"
    if echo "$PATH" | grep -q "node"; then
        log "Node.js-related directories found in PATH."
        echo "$PATH" | tr ':' '\n' | grep "node" | while read -r path; do
            log "  PATH entry: $path"
        done
    else
        log "No Node.js-related directories in PATH."
    fi

    # 3. Symlink checks for node, npm, npx
    log "Checking for node, npm, npx symlinks in common bin directories..."
    for bin in node npm npx; do
        for dir in /usr/local/bin /usr/bin /bin /usr/sbin /sbin; do
            [ -e "$dir/$bin" ] || continue
            if [ -L "$dir/$bin" ]; then
                TARGET=$(readlink "$dir/$bin")
                log "Symlink: $dir/$bin -> $TARGET"
            else
                log "File: $dir/$bin (not a symlink)"
            fi
        done
    done

    # 4. Find all executables named node, npm, npx
    log "Scanning filesystem for all node, npm, npx executables (may take a while)..."
    for bin in node npm npx; do
        find / -type f -name "$bin" -perm /111 2>/dev/null | while read -r f; do
            ver="$("$f" -v 2>/dev/null || echo 'N/A')"
            log "Found $bin: $f (version: $ver)"
        done
    done

    # 5. List running processes for node
    log "Listing running node processes..."
    pgrep -af node | while read -r line; do
        log "Node process: $line"
    done

    log "Node.js verification complete."
    send_email
}

# Do not call the function here. It will be called from main.sh.

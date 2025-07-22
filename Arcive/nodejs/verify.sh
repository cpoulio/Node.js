#!/bin/bash
# verify.sh - Defines verify_nodejs function to check for installed Node.js versions, log, and email results

# This script does NOT source any other scripts. Sourcing is handled by main.sh.
# Only the function is defined here for reuse.


verify() {
    LOG_FILE="verify_nodejs.log"
    > "${LOGDIR}/${LOG_FILE}"
    log "Starting Node.js verification..."

    # 1. Node.js & NPM versions for current user
    for cmd in node npm npx; do
        if command -v "$cmd" >/dev/null 2>&1; then
            ver="$($cmd -v 2>/dev/null || echo 'n/a')"
            log "$cmd version: $ver"
        else
            log "$cmd version: Not found"
        fi
    done

    # 2. PATH entries for all system users
    log "Checking PATH entries for all system users containing 'node'..."
    getent passwd | while IFS=: read -r uname _ _ _ _ homedir shell; do
        if [ -d "$homedir" ] && [ -n "$shell" ] && [ -x "$shell" ]; then
            userpath=$(su -l "$uname" -c 'echo $PATH' 2>/dev/null)
            if printf '%s\n' "$userpath" | tr ':' '\n' | grep -iq node; then
                printf '%s\n' "$userpath" | tr ':' '\n' | grep -i node | while read -r p; do
                    log "User '$uname' has PATH entry: $p"
                done
            fi # end inner if (PATH contains node)
        fi # end outer if (valid home and shell)
    done

    # 3. Symlinks for node, npm, npx
    log "Checking for node, npm, npx symlinks in standard bin directories..."
    for bin in node npm npx; do
        for dir in /usr/local/bin /usr/bin /bin /usr/sbin /sbin /snap/bin; do
            if [ -e "${dir}/${bin}" ]; then
                if [ -L "${dir}/${bin}" ]; then
                    target=$(readlink "${dir}/${bin}")
                    log "Symlink: ${dir}/${bin} -> $target"
                else
                    log "File: ${dir}/${bin} exists (not a symlink)"
                fi
            fi
        done
    done

    # 4. Find all executables in filesystem and warn if in vital OS paths
    log "Scanning filesystem for any node, npm, npx executables..."
    for bin in node npm npx; do
        find / -path /proc -prune -o -type f -name "$bin" -perm /111 -print 2>/dev/null | while read -r f; do
            ver="$($f -v 2>/dev/null || echo 'N/A')"
            case "$f" in
                /bin/*|/sbin/*|/usr/bin/*|/usr/sbin/*)
                    log "WARNING: Found $bin in vital OS path: $f (version: $ver) -- DO NOT DELETE unless you are absolutely sure!"
                    ;;
                *)
                    log "Found $bin: $f (version: $ver)"
                    ;;
            esac
        done
    done

    # 5. Running Node processes
    log "Listing running processes using node..."
    pgrep -af node | while read -r line; do
        log "Node process: $line"
    done

    log "Node.js verification complete."
    send_email
}

# Do not call the function here. It will be called from main.sh.

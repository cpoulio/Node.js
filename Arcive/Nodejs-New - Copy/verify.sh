#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR
####################################################################################################
echo "---------------------------Starting Verify.sh Script-----------------------------"

source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'

verify() {
    log "Verify Nodejs($SOFTWARENAME) Function"
    ACTION_PERFORMED="Verify Nodejs"
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    # 1. Node.js & NPM versions for current user
    mapfile -t node_binaries < <(find / -type f -executable -name "node" 2>/dev/null)
    for node_path in "${node_binaries[@]}"; do
        if [[ "$($node_path -v 2>/dev/null)" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            version="$($node_path -v 2>/dev/null)"
            log "Node.js found: $node_path (version: $version)"
        else
            log "Not Valid Node.js: $node_path"
        fi
    done

    # 2. PATH contents for all users.
    log "Checking PATH entries for all system users containing 'node'..."
    getent passwd | while IFS=: read -r uname _ _ _ _ homedir shell; do
        case "$shell" in
            *bash|*sh|*zsh)
                if [[ -d "$homedir" ]]; then
                    userpath=$(su -l "$uname" -c 'echo $PATH' 2>/dev/null)
                    if [[ -n "$userpath" ]]; then
                        printf '%s\n' "$userpath" | tr ':' '\n' | grep -i node | while read -r p; do
                            log "User $uname has PATH entry: $p"
                        done
                    fi
                fi
                ;;
        esac
    done

    # 3. Symlink for node, npm, npx
    log "Checking for node, npm, npx symlinks in standard bin directories..."
    for bin in node npm npx; do
        for dir in /usr/local/bin /usr/bin /bin /usr/sbin /sbin /snap/bin; do
            if [[ -e "${dir}/${bin}" ]]; then
                if [[ -L "${dir}/${bin}" ]]; then
                    target=$(readlink "${dir}/${bin}")
                    log "Symlink: ${dir}/${bin} -> $target"
                else
                    log "File: ${dir}/${bin} (not a symlink)"
                fi
            fi
        done
    done

    # 4. Find all executables in filesystem and warn if in vital OS paths
    log "Scanning filesystem for any node, npm, npx executables (may take a while)..."
    for bin in node npm npx; do
        find / -path /proc -prune -o -type f -name "$bin" -perm /111 -print 2>/dev/null | while read -r f; do
            if [[ -x "$f" ]]; then
                ver="$("$f" -v 2>/dev/null || echo 'N/A')"
            else
                ver="N/A"
            fi

            # Now check if files is in a virtual path
            case "$f" in
                /bin/*|/sbin/*|/usr/bin/*|/usr/sbin/*)
                    log "WARNING: Found $bin in vital OS path: $f (version: $ver) -- DO NOT DELETE unless sure."
                    ;;
                *)  
                    log "Found $bin: $f (version: $ver)"
                    ;;
            esac
        done
    done

    # 5. Running NodeJS processes
    log "Listing running node processes using node..."
    pgrep -af node | while read -r line; do
        log "Node process: $line"
    done

    log "Node.js verification complete."
    send_email
}

# Do not call the function here. It will be called from main.sh.

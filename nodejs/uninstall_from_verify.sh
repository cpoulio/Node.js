#!/bin/bash
# uninstall_from_verify.sh - Uninstall Node.js, npm, and npx based on what verify.sh finds
# This script parses the output of verify.sh to precisely uninstall detected Node.js installations and related binaries.

LOGDIR="${LOGDIR:-.}"
LOG_FILE="verify_nodejs.log"

uninstall_from_verify() {
    # Run verify to ensure log is up to date
    verify

    # Parse the log for found Node.js, npm, npx executables
    local found_bins=()
    while IFS= read -r line; do
        # Example: Found node: /usr/local/bin/node (version: v20.18.1)
        if [[ $line =~ ^Found\ (node|npm|npx):\ (.*)\ \(version: ]]; then
            bin_path="${BASH_REMATCH[2]}"
            found_bins+=("$bin_path")
        fi
    done < "${LOGDIR}/${LOG_FILE}"

    # Remove each found binary
    for bin in "${found_bins[@]}"; do
        if [[ -e "$bin" ]]; then
            echo "Removing $bin..."
            sudo rm -f "$bin"
        fi
    done

    # Remove symlinks for node, npm, npx in common bin dirs
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

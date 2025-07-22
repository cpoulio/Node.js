#!/bin/bash
# uninstall_from_verify.sh - Uninstall Node.js, npm, and npx based on what verify.sh finds
# This script parses the output of verify.sh to precisely uninstall detected Node.js installations and related binaries,
# but skips any files that are flagged as vital OS path warnings.
LOGDIR="${LOGDIR:-.}"
LOG_FILE="verify_nodejs.log"

uninstall_from_verify() {
    # Make sure your in root
    ensure_root
    
    # Run verify to ensure log is up to date
    verify



    # Parse the log for found Node.js, npm, npx executables, but skip vital OS path warnings
    local found_bins=()
    local vital_bins=()
    while IFS= read -r line; do
        # Skip any WARNING lines for vital OS paths
        if [[ $line =~ ^WARNING:\ Found\ (node|npm|npx)\ in\ vital\ OS\ path:\ (.*)\ \(version:\ .*\)$ ]]; then
            vital_bins+=("${BASH_REMATCH[2]}")
            continue
        fi
        # Example: Found node: /usr/local/bin/node (version: v20.18.1)
        if [[ $line =~ ^Found\ (node|npm|npx):\ (.*)\ \(version:\ .*\) ]]; then
            bin_path="${BASH_REMATCH[2]}"
            found_bins+=("$bin_path")
        fi
    done < "${LOGDIR}/${LOG_FILE}"

    # Remove each found binary, but skip any that are in vital_bins
    for bin in "${found_bins[@]}"; do
        skip=0
        for vital in "${vital_bins[@]}"; do
            if [[ "$bin" == "$vital" ]]; then
                echo "Skipping vital OS path binary: $bin"
                skip=1
                break
            fi
        done
        if [[ $skip -eq 0 && -e "$bin" ]]; then
            echo "Removing $bin..."
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

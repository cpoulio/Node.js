#!/bin/bash
#set -x
# Description:
# This script automates the installation of ${SOFTWARENAME} 18 and verification in one st
# It dynamically sets the installation log file based on the detected ${SOFTWARENAME}18 (
# and performs cleanup during uninstallation.

# Usage:
# To install and verify ${SOFTWARENAME}18, place the ${SOFTWARENAME}18.tar.xz and the lic
# To uninstall NodeJS, run: ./Nodejs.sh uninstall
# To update NodeJS, run: ./Nodejs.sh update
# To add Email address NodeJS, run: ./Nodejs.sh EMAIL=email@irs.gov

uninstall_all() {

    log "Starting Agressive Uninstall ${SOFTWARENAME} Function"
    ACTION_PERFORMED='Uninstall_All'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    rm -Rf "${INSTALLDIR}"
    rm -Rf /usr/local/lib/node*
    rm -Rf /usr/local/bin/node
    rm -Rf /usr/local/bin/npm
    rm -Rf /usr/local/bin/npx

    # Locate the node binary and proceed only if found
    NODE_PATH=$(which node)
    if [ -n "$NODE_PATH" ]; then
        NODEJS_DIR=$(dirname "${NODE_PATH}")
        log "Node.js installation directory determined: ${NODEJS_DIR}"

        # Find and remove all Node.js installation directories
        for NODEJS_DIR in ${NODEJS_DIR}/node-v*; do
            if [ -d "${NODEJS_DIR}" ]; then
                rm -rf "${NODEJS_DIR}" && log "${SOFTWARENAME} ${NODEJS_DIR} directory removed."
            fi
        done
    else
        log "${SOFTWARENAME} installed not found."
    fi

    # Remove other potential Node.js installation paths
    NODE_BIN_DIR=$(dirname "$NODE_PATH")
    if [ -d "$NODE_BIN_DIR" ]; then
        rm -rf "$NODE_BIN_DIR" && log "${SOFTWARENAME} ${NODE_BIN_DIR} directory removed."
    fi

    # Remove symbolic links
    rm -f /usr/local/bin/npx && log "${SOFTWARENAME} npx file removed." || log 'Failed to remove npx symlink'
    rm -f /usr/local/bin/npm && log "${SOFTWARENAME} npm file removed." || log 'Failed to remove npm symlink'
    rm -f /usr/local/bin/node && log "${SOFTWARENAME} node file removed." || log 'Failed to remove node symlink'
    
    log "Removing Node.js related entries from profile files..."
    remove_nodejs_path_entries
    
    backup_and_remove_old_paths

    log "${SOFTWARENAME} removed cleanly."

    log "Running verify"
    verify

    send_email
}

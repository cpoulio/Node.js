#!/bin/bash
# uninstall.sh - NodeJS uninstall function and dependencies

log() {
    echo "${DATE} - $1" | tee -a "${LOGDIR}/${LOG_FILE}"
}

backup_and_remove_old_paths() {
    log 'Backing up and removing old paths from profile files...'
    for PROFILE in ~/.bash_profile ~/.profile ~/.bashrc ~/.zshrc; do
        if [ -f "$PROFILE" ]; then
            cp -p "$PROFILE" "${PROFILE}.bak" | tee -a "${LOGDIR}/${LOG_FILE}"
            log "$PROFILE backed up"
            sed -i "/${INSTALLDIR//\//\\/}\/node-v.*\/bin/d" "$PROFILE"
            sed -i "/export PATH=${NODE_BIN_DIR//\//\\/}:\$PATH/d" "$PROFILE"
            log "$PROFILE updated to remove old paths"
        fi
    done
}

send_email() {
    echo 'Sending-email notification...'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOG_FILE} successfully."
    echo "🔹 Executing: ${EMAIL_SUBJECT}" $EMAIL_LIST
    echo "🔹 DEBUG: FINAL EMAIL LIST BEFORE MAILX: [$EMAIL_LIST]"
    mailx -s "${EMAIL_SUBJECT}" $EMAIL_LIST < "${LOGDIR}/${LOG_FILE}"
}

uninstall() {
    log "Starting Safe Uninstall ${SOFTWARENAME} Function"
    ACTION_PERFORMED='Uninstall'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"
    if [ -d "${INSTALLDIR}/${NODEJSFILE}" ]; then
        rm -rf "${INSTALLDIR:?}/${NODEJSFILE}" && log "${SOFTWARENAME} ${NODEJSFILE} directory removed."
    else
        log "${SOFTWARENAME} ${NODEJSFILE} directory not found."
    fi
    for bin in node npm npx; do
        BIN_PATH="/usr/local/bin/$bin"
        if [ -L "$BIN_PATH" ]; then
            TARGET=$(readlink "$BIN_PATH")
            if [[ "$TARGET" == "${INSTALLDIR}/${NODEJSFILE}/bin/$bin" ]]; then
                rm -f "$BIN_PATH" && log "$bin symlink removed from /usr/local/bin."
            fi
        fi
    done
    backup_and_remove_old_paths
    log "${SOFTWARENAME} safely removed."
    log "Uninstall completed."
    send_email
}

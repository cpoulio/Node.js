#!/bin/bash
shopt -s extglob
#set -x
set -euo pipefail

update() {
    echo "--------------------Starting Update.sh Script--------------------"
    ACTION_PERFORMED='Update'
    # Force source the functions
    source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
    source ./uninstall.sh && echo 'Sourced: uninstall.sh'
    source ./install.sh && echo 'Sourced: install.sh'  

    LOG_FILE="${ACTION_PERFORMED}.log"
    # Call the functions directly
    uninstall 2>&1 | tee -a "$(get_log_file_path)"
    install 2>&1 | tee -a "$(get_log_file_path)"

    send_email || log "send_email function not found, skipping email."
    log "--------------------Update.sh Script Completed--------------------"
}
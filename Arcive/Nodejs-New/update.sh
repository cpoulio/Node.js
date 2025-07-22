#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail
################################################################################
source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
ACTION_PERFORMED='Update'
LOG_FILE=$(generate_log_file_name)

echo "--------------------Starting Update.sh Script--------------------"

update() {

    log "Starting ${ACTION_PERFORMED} ${SOFTWARENAME} Function"

    echo "$DATE - Starting Update NodeJS Function"

    echo "$DATE - Running: OPTION=uninstall_from_verify ./setup.sh"
    OPTION=uninstall_from_verify ./setup.sh

    echo "$DATE - Running: OPTION=install ./setup.sh"
    OPTION=install ./setup.sh

    echo "$DATE - Reloading profile to activate updated NodeJS path"
    source ~/.bash_profile

    echo "$DATE - Update process completed."
}

update
send_email

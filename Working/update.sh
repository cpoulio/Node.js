#!/bin/bash
shopt -s extglob
#set -x
set -euo pipefail

echo "--------------------Starting Update.sh Script--------------------"
ACTION_PERFORMED='Update'
# Force source the functions
source ./variables_functions.sh
source ./uninstall_from_verify.sh
source ./install.sh
source ./verify.sh

LOG_FILE="${ACTION_PERFORMED}.log"
# Call the functions directly
uninstall_from_verify 2>&1 | tee -a "$(get_log_file_path)"
install 2>&1 | tee -a "$(get_log_file_path)"
verify 2>&1 | tee -a "$(get_log_file_path)"

log "--------------------Update.sh Script Completed--------------------"
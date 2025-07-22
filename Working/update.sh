#!/bin/bash

shopt -s extglob
set -euo pipefail

echo "--------------------Starting Update.sh Script--------------------"

# Force source the functions
source ./variables_functions.sh

# Source the scripts to get their functions
source ./uninstall_from_verify.sh
source ./install.sh
source ./verify.sh

# Call the functions directly
uninstall_from_verify 2>&1 | tee -a "${LOGDIR}/${LOG_FILE}"
install 2>&1 | tee -a "${LOGDIR}/${LOG_FILE}"
verify 2>&1 | tee -a "${LOGDIR}/${LOG_FILE}"

log "--------------------Update.sh Script Completed--------------------"
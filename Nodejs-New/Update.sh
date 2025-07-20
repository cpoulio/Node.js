#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail
################################################################################

echo "--------------------Starting Update.sh Script--------------------"

source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
source ./uninstall_from_verify.sh && echo 'Sourced: uninstall_from_verify.sh'
source ./install.sh && echo 'Sourced: install.sh'

# Description:
# This script automates the installation of ${SOFTWARENAME} 18 and verification in one step.
# It dynamically sets the installation log file based on the detected ${SOFTWARENAME}18 Quickstart jar
# and performs cleanup during uninstallation.
#
# Usage:
# To install and verify ${SOFTWARENAME}18, place the ${SOFTWARENAME}18.tar.xz and the license properties
# To uninstall NodeJS, run: ./Nodejs.sh uninstall
# To update NodeJS, run: ./Nodejs.sh update
# To add Email address NodeJS, run: ./Nodejs.sh EMAIL=email@irs.gov

update() {
    log "Starting Update ${SOFTWARENAME} Function"
    ACTION_PERFORMED='Update'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    #### UnInstall function ####
    uninstall_from_verify

    #### Install function ####
    install

    # Log the completion of the update process
    log "${SOFTWARENAME} update complete."

    # Send an email notification
    send_email
}

#!/bin/bash

# Description:
# This script automates the installation of ${SOFTWARENAME} 18 and verification in one step.
# It dynamically sets the installation log file based on the detected ${SOFTWARENAME}18 Quickstart jar
# and performs cleanup during uninstallation.
#
# Usage:
# To install and verify ${SOFTWARENAME}18, place the ${SOFTWARENAME}18.tar.xz and the license properties file in the same directory as this script and run: ./${SOFTWARENAME}.sh install
# To uninstall NodeJS, run: ./Nodejs.sh uninstall
# To update NodeJS, run: ./Nodejs.sh update
# To add Email address NodeJS, run: ./Nodejs.sh EMAIL=email@irs.gov
#"Deployment Directory=${deploy_dir}" is VERY important. This is for Ansible and has to represent the directory that has the scripts and binaries.

## Common Variables ############################################################################################################################################################

#deploy_dir='.' # Comment out when deploying with Ansible.
VERSION='20.18.1'
NPM_VERSION='10.8.2'
EMAIL_LIST="christopher.g.pouliot@irs.gov${EMAIL:+ $EMAIL}"

### Variables that Do Not Change Much ######
SOFTWARENAME='NodeJS'
HOSTNAME="$(uname -n)"
INSTALLDIR='/usr/local/lib/nodejs'
LOGDIR="/tmp"
NODE_VERSION="v${VERSION}"
LINUX_DISTRO='linux-x64'
NODEJSFILE="node-${NODE_VERSION}-${LINUX_DISTRO}"
FILEPATH="${INSTALLDIR}/${NODEJSFILE}/bin"
YUM_PACKAGES="openssl-devel bzip2-devel libicu-devel gcc-c++ make"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"

## Check Variables ############################################################################################################################################################
echo "Deployment Directory=${deploy_dir}"
echo "${NODEJSFILE}"
echo "${FILEPATH}"
echo "${NODE_VERSION}"
echo "DATE=${DATE}"
printf "DATE=%s\n" ${DATE}
echo "${EMAIL_LIST}"

# Extract command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --email)
            if [[ -n "$2" ]]; then
                EMAIL="$2"
                shift 2
            fi
            ;;
        *)
            echo "❌ Invalid argument: $1"
            exit 1
            ;;
    esac
done


# Ensure MODE is set (default to install if missing)
if [[ -z "$MODE" ]]; then
    echo "❌ Error: --mode is required."
    exit 1
fi

# Ensure only valid modes are accepted
if [[ ! "$MODE" =~ ^(install|uninstall|update)$ ]]; then
    echo "❌ Invalid mode: $MODE. Use --mode install, uninstall, or update."
    exit 1
fi




## Common Functions ############################################################################################################################################################

log() {
    echo "${DATE} - $1" | tee -a "${LOGDIR}/${LOG_FILE}"
}

send_email() {
    echo 'Sending-email notification...'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOG_FILE} successfully."
    echo "🔹 Executing: ${EMAIL_SUBJECT}" $EMAIL_LIST
    echo "🔹 DEBUG: FINAL EMAIL LIST BEFORE MAILX: [$EMAIL_LIST]"
    mailx -s "${EMAIL_SUBJECT}" $EMAIL_LIST < "${LOGDIR}/${LOG_FILE}"
}

install_YUM_packages() {
    # YUM Installation Sequence.
    echo "Starting YUM Installation..."
    yum install -y ${YUM_PACKAGES} 2>&1 | tee -a "${LOGDIR}/${LOG_FILE}"
    if [ $? -ne 0 ]; then
        log 'Failed to install prerequisites. Exiting.'
        exit 1
    fi
    log 'Prerequisites libraries installed successfully.'
}

extract_nodejs() {

    # Check if the ${SOFTWARENAME} tar file was found
    if [ ! -f "${deploy_dir}/${NODEJSFILE}.tar.xz" ]; then
        log "${SOFTWARENAME} TAR not found."
        exit 1
    else
        log "TAR Found ${NODEJSFILE}.tar.xz."
    fi

    #  Extract ${SOFTWARENAME}
    log "Extracting ${NODEJSFILE}..."
    mkdir -p ${INSTALLDIR}
    tar -xJf "${deploy_dir}/${NODEJSFILE}.tar.xz" -C ${INSTALLDIR} 2>&1 | tee -a "${LOGDIR}/${LOG_FILE}"
    if [ $? -ne 0 ]; then
        log "Failed to extract ${NODEJSFILE}."
        exit 1
    else
        log "Successfully extracted ${NODEJSFILE}."

    fi
}

update_bash_profile() {
    log 'Updating profile files...'
    # Backup profile files
    cp -p ~/.bash_profile ~/.bash_profile.bak
    log 'bash_profile backed up'

    # Update .bash_profile using variables
    sed -i -e 's|^PATH=\$PATH:\$HOME/bin|#PATH=\$PATH:\$HOME/bin|' ~/.bash_profile
    echo "export PATH=${INSTALLDIR}/${NODEJSFILE}/bin:\$PATH" >> ~/.bash_profile
    log '.bash_profile updated'

    # Reload profile
    . ~/.bash_profile
    log 'Profile reloaded'
}

temp_profile() {
    export PATH=${INSTALLDIR}/${NODEJSFILE}/bin:$PATH
}

backup_and_remove_old_paths() {
    log 'Backing up and removing old paths from profile files...'

    # Backup and remove old paths from profiles
    for PROFILE in ~/.bash_profile ~/.profile ~/.bashrc ~/.zshrc; do
        if [ -f "$PROFILE" ]; then
            cp -p "$PROFILE" "${PROFILE}.bak" | tee -a "${LOGDIR}/${LOG_FILE}"
            log "${PROFILE} backed up"
            sed -i "/${INSTALLDIR//\//\\/}\/node-v.*\/bin/d" "$PROFILE"
            sed -i "/export PATH=${NODE_BIN_DIR//\//\\/}:\$PATH/d" "$PROFILE"
            log "${PROFILE} updated to remove old paths"
        fi
    done
}


### Combined install and verify function ############################################################################################################################################################

install() {

    log 'Starting Install and Verify Function'
    ACTION_PERFORMED='Install and Verify'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    install_YUM_packages # Installing YUM packages function.

    extract_nodejs # Check if the ${SOFTWARENAME} tar file was found and Extract ${SOFTWARENAME} function.

    temp_profile # Call the function to update and source .bash_profile

    # Locate binaries using which
    NODE_BIN_PATH=$(which node)
    NPM_BIN_PATH=$(which npm)
    NPX_BIN_PATH=$(which npx)

    # Create and verify symbolic link for node
    echo "Establishing symbolic links..."
    ln -sf "${NODE_BIN_PATH}" /usr/local/bin/node
    if [ -L /usr/local/bin/node ] && [ -x /usr/local/bin/node ]; then
        log "Symbolic link for node created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to node."
        exit 1
    fi
    # Create and verify symbolic link for npm
    ln -sf "${NPM_BIN_PATH}" /usr/local/bin/npm
    if [ -L /usr/local/bin/npm ] && [ -x /usr/local/bin/npm ]; then
        log "Symbolic link for npm created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to npm."
        exit 1
    fi
    # Create and verify symbolic link for npx
    ln -sf "${NPX_BIN_PATH}" /usr/local/bin/npx
    if [ -L /usr/local/bin/npx ] && [ -x /usr/local/bin/npx ]; then
        log "Symbolic link for npx created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to npx."
        exit 1
    fi
    echo "Node Version Installed: ${NODE_VERSION}"

    # Verify installation
    log "Verifying the install of ${SOFTWARENAME} at version ${NODE_VERSION}"
    NODECHECK=$(${FILEPATH}/node -v)
    if [[ "${NODECHECK}" = "${NODE_VERSION}" ]]; then
        log "${SOFTWARENAME} ${NODE_VERSION} has been successfully installed"
    else
        log '${SOFTWARENAME} installation failed'
        exit 2
    fi

    NPMCHECK=$(${FILEPATH}/npm -v)
    if [[ "${NPMCHECK}" = "${NPM_VERSION}" ]]; then
        log "npm updated to version ${NPMCHECK}"
    else
        log 'npm update failed'
        exit 2
    fi

    # Set npm logging level
    log 'Setting npm logging level...'
    NPM_PATH=$(which npm)
    if [ -x "$NPM_PATH" ]; then
        $NPM_PATH config set loglevel warn
        if [ $? -eq 0 ]; then
            log 'npm logging level set to warn successfully'
        else
            log 'Failed to set npm logging level'
        fi
    else
        log 'npm binary not found or not executable'
    fi

    update_bash_profile # Final profile update

    log "Installation and verification completed."
    send_email

}

### Uninstall ############################################################################################################################################################

uninstall() {

    log "Starting Uninstall ${SOFTWARENAME} Function"
    ACTION_PERFORMED='Uninstall'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    rm -Rf ${INSTALLDIR}
    rm -Rf /usr/local/lib/node*
    rm -Rf /usr/local/bin/node*
    rm -Rf /usr/local/bin/npm*
    rm -Rf /usr/local/bin/npx*

    # Locate the node binary and proceed only if found
    NODE_PATH=$(which node)
    if [ -n "$NODE_PATH" ]; then
        log "${SOFTWARENAME} installation found at ${NODE_PATH}"

        # Determine the installation directory
        NODEJS_DIR=$(dirname $(dirname "$NODE_PATH"))
        log "Node.js installation directory determined: ${NODEJS_DIR}"

        # Find and remove all Node.js installation directories
        for NODEJS_DIR in ${NODEJS_DIR}/node-v*; do
            if [ -d "$NODEJS_DIR" ]; then
                rm -rf "$NODEJS_DIR" && log "${SOFTWARENAME} ${NODEJS_DIR} directory removed." || log "Failed to remove ${NODEJS_DIR} or it has already been uninstalled."
            fi
        done
    else
        log "${SOFTWARENAME} installed not found."
    fi

    # Remove other potential Node.js installation paths
    NODE_BIN_DIR=$(dirname "$NODE_PATH")
    if [ -d "$NODE_BIN_DIR" ]; then
        rm -rf "$NODE_BIN_DIR" && log "${SOFTWARENAME} ${NODE_BIN_DIR} directory removed." || log "Failed to remove ${NODE_BIN_DIR}."
    fi

    # Remove symbolic links
    rm -f /usr/local/bin/npx  && log "${SOFTWARENAME} npx file removed." || log 'Failed to remove npx.'
    rm -f /usr/local/bin/npm  && log "${SOFTWARENAME} npm file removed." || log 'Failed to remove npm.'
    rm -f /usr/local/bin/node && log "${SOFTWARENAME} node file removed." || log 'Failed to remove node.'

    backup_and_remove_old_paths

    log "${SOFTWARENAME} removed cleanly."
    log "Uninstall completed."

    send_email

}

### Update ############################################################################################################################################################

update() {
    log "Starting Update ${SOFTWARENAME} Function"
    ACTION_PERFORMED='Update'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    #### UnInstall function ####
    uninstall

    #### Install function ####
    install

    # Log the completion of the update process
    log "${SOFTWARENAME} update complete."

    # Send an email notification
    send_email
}

## Main Execution Logic ############################################################################################################################################################

case ${MODE} in
    install) install ;;
    uninstall) uninstall ;;
    update) update ;;
    *) echo "Invalid mode. Usage: MODE=(install|uninstall|update)" ; exit 1 ;;
esac
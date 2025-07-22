#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail

##########################################################

echo "-------------------Starting Install.sh Script----------------------------"

source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'

echo "Starting Install Script"
ensure_root "$@"

    log 'Starting Install and Verify Function'
    ACTION_PERFORMED='Install and Verify'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

update_bash_profile() {
    log 'Updating profile files...'
    # Backup profile files
    cp -p ~/.bash_profile ~/.bash_profile.bak
    log 'bash_profile backed up'

    # Update .bash_profile using variables
    sed -i -e 's|\$PATH:\$PATH:$HOME/bin|:$PATH:$HOME/bin|' ~/.bash_profile
    echo "export PATH=${INSTALLDIR}/${NODEJSFILE}/bin:\$PATH" >> ~/.bash_profile
    log '.bash_profile updated'

    # Reload profile
    . ~/.bash_profile
    log 'Profile reloaded'
}

temp_profile() {
    export PATH=${INSTALLDIR}/${NODEJSFILE}/bin:$PATH
}

extract_nodejs() {

    # Check if the ${SOFTWARENAME} tar file was found
    if [ ! -f "${deploy_dir}/${NODEJSFILE}.tar.xz" ]; then
        log "${SOFTWARENAME} TAR not found."
        exit 1
    else
        log "TAR Found ${NODEJSFILE}.tar.xz."
    fi

    # Extract ${SOFTWARENAME}
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
    if [ ! -x /usr/local/bin/node ]; then
        log "Symbolic link for node created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to node."
        exit 1
    fi

    # Create and verify symbolic link for npm
    ln -sf "${NPM_BIN_PATH}" /usr/local/bin/npm
    if [ ! -x /usr/local/bin/npm ]; then
        log "Symbolic link for npm created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to npm."
        exit 1
    fi

    # Create and verify symbolic link for npx
    ln -sf "${NPX_BIN_PATH}" /usr/local/bin/npx
    if [ ! -x /usr/local/bin/npx ]; then
        log "Symbolic link for npx created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to npx."
        exit 1
    fi

    echo "Node Version Installed: ${NODE_VERSION}"

    # Verify installation
    log "Verifying the install of ${SOFTWARENAME} at version ${NODE_VERSION}"
    NODECHECK=$(${FILEPATH}/node -v)
    if [[ "${NODECHECK}" == "${NODE_VERSION}" ]]; then
        log "${SOFTWARENAME} ${NODE_VERSION} has been successfully installed"
    else
        log "${SOFTWARENAME} installation failed"
        exit 2
    fi

    NPMCHECK=$(${FILEPATH}/npm -v)
    if [[ "${NPMCHECK}" == "${NPM_VERSION}" ]]; then
        log "npm updated to version ${NPMCHECK}"
    else
        log "npm update failed"
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

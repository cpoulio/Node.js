#!/bin/bash

# Description:
# This script automates the installation of ${SOFTWARENAME} 18 and verification in one step.
# It dynamically sets the installation log file based on the detected ${SOFTWARENAME}18 Quickstart jar
# and performs cleanup during uninstallation.
#
# Usage:
# To install and verify ${SOFTWARENAME}18, place the ${SOFTWARENAME}18.tar.xz and the license properties file in the same directory as this script and run: ./${SOFTWARENAME}.sh install
# To uninstall ${SOFTWARENAME}18, simply run: ./${SOFTWARENAME}.sh uninstall
#"Deployment Directory=${deploy_dir}" is VERY important. This is for Ansible and has to represent the directory that has the scripts and binaries.

## Common Variables ############################################################################################################################################################

#deploy_dir='.' # Comment out when deploying with Ansible.
SOFTWARENAME='NodeJS'
EMAIL_RECIPIENT='christopher.g.pouliot@irs.gov'
HOSTNAME="$(uname -n)"
INSTALLDIR='/usr/local/lib/nodejs21'
LOGDIR="/tmp"
VERSION18='21.7.3'
NPM_VERSION='10.5.0'
NODE_VERSION="v${VERSION18}"
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

## Check for command-line arguments for MODE #### ***VERY IMPORTANT**** ###
for ARG in "$@"
do
    case $ARG in
        install|uninstall)
            echo "Arg: $ARG"
            MODE=$ARG # Important Override MODE if provided as a command-line argument
            echo "MODE=${MODE}" #Important to check what Option is passed for MODE
            printf "MODE=%s\n" ${MODE} #Important to check what Option is passed for MODE
            ;;
        *)
            # Handle other arguments or ignore
            ;;
    esac
done

## Common Functions ############################################################################################################################################################

log() {
    echo "${DATE} - $1" | tee -a "${LOGDIR}/${LOG_FILE}"
}

send_email() {
    echo 'Sending email notification...'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOG_FILE} successfully."
    cat "${LOGDIR}/${LOG_FILE}" | mailx -s "$EMAIL_SUBJECT" "$EMAIL_RECIPIENT"
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

        log 'Fixing npm logging issue...'
        cd "${INSTALLDIR}/${NODEJSFILE}/lib/node_modules/npm/node_modules/npmlog/lib"
        cp 'log.js' 'log.js.org'
        sed -i -e 's|log.progressEnabled|//log.progressEnabled|' 'log.js'
        if grep '//log.progressEnabled' log.js > /dev/null; then
            log 'npm logging fix applied successfully'
        else
            log 'npm logging fix failed'
        fi
    fi
}

## Combined install and verify function ############################################################################################################################################################

install() {
    log 'Starting Install and Verify Function'
    ACTION_PERFORMED='Install and Verify'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    install_YUM_packages # Installing YUM packages function.

    extract_nodejs # Check if the ${SOFTWARENAME} tar file was found and Extract ${SOFTWARENAME} function.

    # Update bash_profile
    echo "Updating .bash_profile..."
    sed -i -e 's|^PATH=\$PATH:\$HOME/bin|#PATH=\$PATH:\$HOME/bin|' ~/.bash_profile
    echo "" >> ~/.bash_profile
    echo "export PATH=${INSTALLDIR}/node-${NODE_VERSION}-${LINUX_DISTRO}/bin:\$PATH" >> ~/.bash_profile # This is where it sets Version with echo
    echo ".bash_profile was updated!"
    . ~/.bash_profile

    # Create and verify symbolic link for node
    echo "Establishing symbolic links..."
    ln -s "${FILEPATH}/node" /usr/local/bin/node
    if [ -L /usr/local/bin/node ] && [ -x /usr/local/bin/node ]; then
        log "Symbolic link for node created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to node."
        exit 1
    fi
    # Create and verify symbolic link for npm
    ln -s "${FILEPATH}/npm" /usr/local/bin/npm
    if [ -L /usr/local/bin/npm ] && [ -x /usr/local/bin/npm ]; then
        log "Symbolic link for npm created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to npm."
        exit 1
    fi
    # Create and verify symbolic link for npx
    ln -s "${FILEPATH}/npx" /usr/local/bin/npx
    if [ -L /usr/local/bin/npx ] && [ -x /usr/local/bin/npx ]; then
        log "Symbolic link for npx created successfully and is executable."
    else
        log "Failed to create or set executable permission for symbolic link to npx."
        exit 1
    fi

    log "Verifying the install of ${SOFTWARENAME} at version ${NODE_VERSION}"
    export PATH="$PATH:/usr/local/bin:/usr/local" # Ensure local bin directores are in the PATH
    echo "Node Version Installed: ${NODE_VERSION}"

    # Verify installation
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

    log "Installation and verification completed."
    send_email
}
## Uninstall ############################################################################################################################################################

uninstall() {
    log "Starting Uninstall ${SOFTWARENAME} Function"
    ACTION_PERFORMED='Uninstall'
    LOG_FILE="node-${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

    if [ -d ${INSTALLDIR} ]; then
        rm -rf "${INSTALLDIR}" && log "${SOFTWARENAME} ${INSTALLDIR} file removed." || log "Failed to remove ${INSTALLDIR}."
        rm -f /usr/local/bin/npx  && log "${SOFTWARENAME} npx file removed." || log 'Failed to remove npx.'
        rm -f /usr/local/bin/npm  && log "${SOFTWARENAME} npm file removed." || log 'Failed to remove npm.'
        rm -f /usr/local/bin/node && log "${SOFTWARENAME} node file removed." || log 'Failed to remove node.'
        cp -p ~/.bash_profile ~/.bash_profile.bak | tee -a "${LOGDIR}/${LOG_FILE}"
        log 'bash_profile backed up'
        sed -i 's/#PATH=/PATH=/' ~/.bash_profile
        sed -i "/node-${NODE_VERSION}-${LINUX_DISTRO}/d" ~/.bash_profile
        sed -i "/LINUX_DISTRO=${LINUX_DISTRO}/d" ~/.bash_profile
        sed -i "\|export PATH=${INSTALLDIR}/node-${NODE_VERSION}-${LINUX_DISTRO}/bin:\$PATH|d" ~/.bash_profile
        sed -i "\|export PATH=\$PATH:\$HOME/bin|d" ~/.bash_profile
        log "${SOFTWARENAME} removed cleanly."
    else
        log "${SOFTWARENAME} does not exist under ${INSTALLDIR}"
    fi

    log "Uninstall completed."
    send_email
}
## Main Execution Logic ############################################################################################################################################################

case ${MODE} in
    install) install ;;
    uninstall) uninstall ;;
    *) echo "Invalid mode. Usage: MODE=(install|uninstall)" ; exit 1 ;;
esac
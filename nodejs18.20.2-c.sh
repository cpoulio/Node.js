#!/bin/bash

# Description:
# This script automates the installation of NodeJS 18 and verification in one step.
# It dynamically sets the installation log file based on the detected NodeJS18 Quickstart jar
# and performs cleanup during uninstallation.

# Usage:
# To install and verify NodeJS18, place the NodeJS18.tar.xz and the license properties file in the same directory as this script and run: ./NodeJS.sh install
# To uninstall NodeJS18, simply run: ./NodeJS.sh uninstall

## Common Variables ############################################################################################################################################################
echo "Deployment Directory=${deploy_dir}"
EMAIL_RECIPIENT=christopher.g.pouliot@irs.gov
HOSTNAME="$(uname -n)"
INSTALLDIR='/usr/local/lib/nodejs18'
NPM10='10.5.0'
VERSION18=v18.20.2
DISTRO18=linux-x64
NODEJSFILE="node-${VERSION18}-${DISTRO18}"
FILEPATH="${INSTALLDIR}/${NODEJSFILE}/bin"
LOGDIR="/tmp"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

## Check Variables ############################################################################################################################################################

echo "NODEJSFILE=${NODEJSFILE}"
echo "FILEPATH=${FILEPATH}"
echo "DATE=${DATE}"
printf "DATE=%s\n" ${DATE}

# Check for command-line arguments for MODE
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
    echo "${DATE} - $1" | tee -a ${LOGDIR}/${LOG_FILE}
}

send_email() {
    # Assumes $EMAIL_SUBJECT and $LOG_FILE_PATH are set appropriately before calling this function
    echo 'Sending email notification...'
    cat ${LOGDIR}/${LOG_FILE} | mailx -s "$EMAIL_SUBJECT" "$EMAIL_RECIPIENT"
}
ACTION_STATUS=0 # Action_status is Indicate successful completion EXTRA

## Combined install and verify function ############################################################################################################################################################

install() {
    log 'Starting Install and Verify Function'
    ACTION_PERFORMED='install_verify'
    LOG_FILE="node-${VERSION18}-${DISTRO18}-${ACTION_PERFORMED}.log"
    EMAIL_SUBJECT="${HOSTNAME}: ${LOGDIR}/${LOG_FILE} ${ACTION_PERFORMED} action completed successfully on ${DATE}."

    # Check if the NodeJS tar file was found
    if [ ! -f "${deploy_dir}/${NODEJSFILE}.tar.xz" ]; then
    #if [ ! -f "./${NODEJSFILE}.tar.xz" ]; then #**Local Testing**#
        log "NodeJS TAR not found."
        exit 1
    fi

    # Installation sequence
    echo "Starting installation..."
    yum install -y openssl-devel bzip2-devel libicu-devel gcc-c++ make 2>&1 | tee -a ${LOGDIR}/${LOG_FILE}
    if [ $? -ne 0 ]; then
        log 'Failed to install prerequisites. Exiting.'
        exit 1
    fi
    log 'Prerequisites libraries installed successfully.'

    # Download and extract NodeJS
    echo "Extracting ${NODEJSFILE}..."
    mkdir -p ${INSTALLDIR}
    tar -xvJf "${deploy_dir}/${NODEJSFILE}.tar.xz" -C ${INSTALLDIR} 2>&1 | tee -a ${LOGDIR}/${LOG_FILE}
    #tar -xvJf "./${NODEJSFILE}.tar.xz" -C ${INSTALLDIR} 2>&1 | tee -a ${LOGDIR}/${LOG_FILE}  #**Local Testing**#
    if [ $? -ne 0 ]; then
        log "Failed to extract ${NODEJSFILE}."
        exit 1
    else
        log "Successfully extracted ${NODEJSFILE}."

        # Fix npm logging issue
        log "Fixing npm logging issue..."
        cd "${INSTALLDIR}/${NODEJSFILE}/lib/node_modules/npm/node_modules/npmlog/lib"
        cp log.js log.js.org
        sed -i -e 's|log.progressEnabled|//log.progressEnabled|' log.js
        if grep "//log.progressEnabled" log.js > /dev/null; then
            log 'npm logging fix applied successfully'
        else
            log 'npm logging fix failed'
        fi
    fi

    # Update bash_profile
    echo "Updating .bash_profile..."
    sed -i -e 's|^PATH=\$PATH:\$HOME/bin|#PATH=\$PATH:\$HOME/bin|' ~/.bash_profile
    echo "" >> ~/.bash_profile
    echo "export PATH=\${INSTALLDIR}/node-\${VERSION18}-\${DISTRO18}/bin:\$PATH" >> ~/.bash_profile
    echo ".bash_profile was updated!"
    . ~/.bash_profile

    # Establish symbolic links and permissions
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

    # Verify installation
    log "Verifying the install of NodeJS ${VERSION18}"
    export PATH="$PATH:/usr/local/bin:/usr/local"

    NODECHECK=$(${FILEPATH}/node -v)
    if [ "${NODECHECK}" = "${VERSION18}" ]; then
        log "NodeJS ${VERSION18} has been successfully installed"
    else
        log 'NodeJS installation failed'
        exit 2
    fi

    NPMCHECK=$(${FILEPATH}/npm -v)
    if [ "${NPMCHECK}" = "${NPM10}" ]; then
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
    log 'Starting Uninstall Function'
    ACTION_PERFORMED='uninstall'
    LOG_FILE="node-${VERSION18}-${DISTRO18}-${ACTION_PERFORMED}.log"
    EMAIL_SUBJECT="${HOSTNAME}: ${LOGDIR}/${LOG_FILE} ${ACTION_PERFORMED} action completed successfully on ${DATE}."
    echo ${LOGDIR}/${LOG_FILE}
    printf "\n" > ${LOGDIR}/${LOG_FILE}

    #Remove NodeJS
    if [ -d ${INSTALLDIR} ]; then
        rm -rf ${INSTALLDIR} && log "NodeJS ${INSTALLDIR} file removed." || log "Failed to remove ${INSTALLDIR}."
        rm -f /usr/local/bin/npx  && log 'NodeJS npx file removed.' || log 'Failed to remove npx.'
        rm -f /usr/local/bin/npm  && log 'NodeJS npm file removed.' || log 'Failed to remove npm.'
        rm -f /usr/local/bin/node && log 'NodeJS node file removed.' || log 'Failed to remove node.'
        cp -p ~/.bash_profile ~/.bash_profile.bak.${DATE}
        sed -i 's/#PATH=/PATH=/' ~/.bash_profile
        sed -i '/VERSION18=v18.20.2/d' ~/.bash_profile
        sed -i '/DISTRO18=linux-x64/d' ~/.bash_profile
        sed -i '/export PATH=${INSTALLDIR}\/lib\/nodejs18\/node-${VERSION18}-${DISTRO18}\/bin:$PATH/d' ~/.bash_profile
        sed -i '/export PATH=$PATH:$HOME\/bin/d' ~/.bash_profile
        log 'NodeJS removed cleanly.'
    else
        log "NodeJS does not exist under ${INSTALLDIR}"
    fi

    log "Installation and verification completed."
    send_email
}

case ${MODE} in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Invalid mode. Usage: MODE={install|uninstall} $0 or $0 {install|uninstall}"
        exit 1
        ;;
esac

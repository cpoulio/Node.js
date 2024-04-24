#!/bin/bash

#################################################################################################################################################################
# Description:
# This script automates the installation, uninstallation, and updating of NodeJS 18.
# It dynamically sets the installation log file based on the detected NodeJS18 Quickstart jar
# and performs cleanup during uninstallation.
#
# Usage:
# To install NodeJS18, place the NodeJS18.tar.xz and the license properties file in the same directory as this script and run: ./NodeJS.sh install
# To uninstall NodeJS18, simply run: ./NodeJS.sh uninstall
# To verify ./NodeJS.sh verify
###################################################################################################################################################################
# Common Variables
EMAIL_RECIPIENT=christopher.g.pouliot@irs.gov
HOSTNAME="$(uname -n)"
INSTALLDIR='/usr/local/lib/nodejs18' # NodeJS Install Directory
VERSION18=v18.20.2
DISTRO18=linux-x64
LOGDIR=/tmp
DATE=`date +%m%d%Y`

echo "MODE=${MODE}"
printf "MODE=%s\n" ${MODE}

##***** IMPORTANT NEED TO RUN SCRIPT ***** Checking for command-line arguments for MODE******##
for ARG in "$@"
do
    case $ARG in
        install|uninstall|verify)
            echo "Arg: $ARG"
            MODE=$ARG  # Important Override MODE if provided as a command-line argument
            echo "MODE=${MODE}" #Important to check what Option is passed for MODE
            printf "MODE=${MODE}"
            ;;
        *)
            # Handle other arguments or ignore
            ;;
    esac
done
####################################################################################################################################

# Common Functions

# Action_status is Indicate successful completion EXTRA
ACTION_STATUS=0

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a ${LOGDIR}/${LOG_FILE}
}

send_email() {
    # Assumes $EMAIL_SUBJECT and $LOG_FILE_PATH are set appropriately before calling this function
    echo 'Sending email notification...'
    cat ${LOGDIR}/${LOG_FILE}| mailx -s "$EMAIL_SUBJECT" "$EMAIL_RECIPIENT"
}

####################################################################################################################################
# Function to install NodeJS18

install() {
    log 'Starting Install Function'
    LOG_FILE='NodeJS-install.log'
    ACTION_PERFORMED='install'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOGDIR}/${LOG_FILE} ${ACTION_PERFORMED} action completed successfully on $(date)."

    printf "\n" > ${LOGDIR}/${LOG_FILE}

    yum install -y openssl-devel bzip2-devel libicu-devel gcc-c++ make 2>&1 |sed G >> ${LOGDIR}/${LOG_FILE}
    if [ $? -ne 0 ]; then
        log 'Failed to install PreReq Libraries. Exiting.'
        exit 1
    else
        log 'PreReq Libraries installed successfully or is already up to date..'
    fi

    PROVERSION=`cat ~/.bash_profile |grep VERSION18= |head -1 |awk -F= '{print $2}'`
    if [ 0${PROVERSION} == 0 ]; then
        echo "${VERSION18}"
        sed -i -e 's|^PATH=\$PATH:\$HOME/bin|#PATH=\$PATH:\$HOME/bin|' ~/.bash_profile
        echo "" >> ~/.bash_profile
        echo "VERSION18=${VERSION18}" >> ~/.bash_profile
        echo "DISTRO18=linux-x64" >> ~/.bash_profile
        echo "export PATH=\${INSTALLDIR}/node-\${VERSION18}-\${DISTRO18}/bin:\$PATH" >> ~/.bash_profile
        echo "export PATH=\$PATH:\$HOME/bin" >> ~/.bash_profile
        echo ".bash_profile was updated!"

        #echo "NodeJS ${PROVERSION} was already installed!"
    elif [[ x${PROVERSION} < "x${VERSION18}" ]]; then
        sed -i -e 's/${PROVERSION}/${VERSION18}/g' ~/.bash_profile
        log ".bash_profile was updated!"
    else
        log ".bash_profile update is not required!"
    fi

    #Refresh .bash_prof
    . ~/.bash_profile > /dev/null

    log "Extracting node-${VERSION18}-${DISTRO18}.tar.xz"

    mkdir -p ${INSTALLDIR}
    tar -xvf node-${VERSION18}-${DISTRO18}.tar.xz -C $INSTALLDIR |sed G >> ${LOGDIR}/${LOG_FILE}
    chmod 755 -R ${INSTALLDIR}

    if [ $? = "0" ]; then
        printf "The command to install NodeJS ${VERSION18} on ${INSTALLDIR} ran successfully" |sed G >> ${LOGDIR}/${LOG_FILE}
        printf "Fixing npm logging issue" |sed G >> ${LOGDIR}/${LOG_FILE}
        cd "${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/lib/node_modules/npm/node_modules/npmlog/lib"
        cp log.js log.js.org
        sed -i -e 's|log.progressEnabled|//log.progressEnabled|' log.js
        if grep "//log.progressEnabled" log.js > /dev/null; then
            printf "npm logging fix applied successfully" |sed G >> ${LOGDIR}/${LOG_FILE}
        else
            printf "npm logging fix failed" |sed G >> ${LOGDIR}/${LOG_FILE}
        fi
    else
    printf "The command to install NodeJS ${VERSION18} on ${INSTALLDIR} may not have run successfully and the install may have failed" |sed G >> ${LOGDIR}/${LOG_FILE}
    fi

    # Establish Symbolic Links
    ln -s "${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/node" /usr/local/bin/node |sed G >> ${LOGDIR}/${LOG_FILE}
    ls -l /usr/local/bin/node |sed G >> ${LOGDIR}/${LOG_FILE}
    ln -s "${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm" /usr/local/bin//npm |sed G >> ${LOGDIR}/${LOG_FILE}
    ls -l /usr/local/bin/npm |sed G >> ${LOGDIR}/${LOG_FILE}
    ln -s "${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npx" /usr/local/bin/npx |sed G >> ${LOGDIR}/${LOG_FILE}
    ls -l /usr/local/bin/npx |sed G >> ${LOGDIR}/${LOG_FILE}

    printf "Updating ownership in ${INSTALLDIR}" |sed G >> ${LOGDIR}/${LOG_FILE}
    find "${INSTALLDIR}" -user 500 -exec chown root:root {} \; >> ${LOGDIR}/${LOG_FILE}

    if [ $? = "0" ]; then
        printf "Updating ownership of ${INSTALLDIR} was successful" |sed G >> ${LOGDIR}/${LOG_FILE}
    else
        printf "Updating ownership of ${INSTALLDIR} failed" |sed G >> ${LOGDIR}/${LOG_FILE}
    fi

    printf "Updating link ownership on ${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm" |sed G >> ${LOGDIR}/${LOG_FILE}
    chown -h root:root "${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm" >> ${LOGDIR}/${LOG_FILE}

    if [ $? = "0" ]; then
        printf "Updating link ownership of ${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm was successful" |sed G >> ${LOGDIR}/${LOG_FILE}
    else
        printf "Updating link ownership of ${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm failed" |sed G >> ${LOGDIR}/${LOG_FILE}
    fi


    printf "\n" >> ${LOGDIR}/${LOG_FILE}
    printf "\n***************Install of NodeJS ${VERSION18} under ${INSTALLDIR} has completed*********\n" >> ${LOGDIR}/${LOG_FILE}
    printf "\n" >> ${LOGDIR}/${LOG_FILE}

    ################################################################################
    # email log file
    ################################################################################

    chmod 775 ${LOGDIR}/${LOG_FILE}
    send_email
}

####################################################################################################################################

uninstall() {
    log 'Starting Uninstall Function'
    LOG_FILE='/NodeJS-uninstall.log'
    ACTION_PERFORMED='uninstall'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOGDIR}/${LOG_FILE} ${ACTION_PERFORMED} action completed successfully on $(date)."
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

    ################################################################################
    # email log file
    ################################################################################

    chmod 775 ${LOGDIR}/${LOG_FILE}
    send_email
}

#######################################################################################################################################

verify() {
    log 'Starting Verify Function'
    LOG_FILE='/NodeJS-verify.log'
    ACTION_PERFORMED='verify'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOGDIR}/${LOG_FILE} ${ACTION_PERFORMED} action completed successfully on $(date)."
    printf "\n" > ${LOGDIR}/${LOG_FILE}

    log "Verifying the install of NodeJS ${VERSION18}"
    export PATH="$PATH:/usr/local/bin:/usr/local"

    #NODECHECK=`/usr/local/bin/node -v`
    NODECHECK="${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/node -v"

    if [[ ${NODECHECK} = "v18.20.2" ]]; then
        log "NodeJS ${VERSION18} ${INSTALLDIR}/node-${VERSION18}-${DISTRO18} has been successfully installed" 
    else
        log 'The installation failed'
        chmod 775 ${LOGDIR}/${LOG_FILE}
        send_email
        exit 2
    fi

    #NPMCHECK="/usr/local/bin/npm -v"
    NPMCHECK="${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm -v"

    if [[ ${NPMCHECK} = "10.5.0" ]]; then
        log "The update of npm to VERSION18 $NPMCHECK ${INSTALLDIR}/node-${VERSION18}-${DISTRO18} was successful" 
    else
        log "The update of npm failed" 
        chmod 775 ${LOGDIR}/${LOG_FILE}
        send_email
        exit 2
    fi

    printf "\nOutput of NPM VERSION ...." >> ${LOGDIR}/${LOG_FILE}
    log ${INSTALLDIR}/node-${VERSION18}-${DISTRO18}/bin/npm version
    #su - buildsrdstestsvc -c "npm VERSION18" >> ${LOGDIR}/${LOG_FILE}

    printf "\n" >> ${LOGDIR}/${LOG_FILE}
    printf "\n***************Verification of NodeJS ${VERSION18} under ${INSTALLDIR}/lib/nodejs/node-${VERSION18}-${DISTRO18} has completed*********\n" >> ${LOGDIR}/${LOG_FILE}
    printf "\n" >> ${LOGDIR}/${LOG_FILE}

    ################################################################################
    # email log file
    ################################################################################

    chmod 775 ${LOGDIR}/${LOG_FILE}
    send_email
}
#######################################################################################################################################
# Main logic to execute functions based on the mode. remove <> and put fuction name.
case ${MODE} in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    verify)
        verify
        ;;
    *)
        echo "Invalid mode. Usage: MODE={install|uninstall|verify} $0 or $0 {install|uninstall|verify}"
        exit 1
        ;;
esac

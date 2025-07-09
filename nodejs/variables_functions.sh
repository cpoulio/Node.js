## Common Variables ############################################################################################################################################################

#deploy_dir='.' # Comment out when deploying with Ansible.
deploy_dir='/opt/actions-runners/binaries'
VERSION='18.20.3'
NPM_VERSION='10.7.0'
EMAIL="christopher.g.pouliot@gmail.com,${EMAIL}"

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
echo "${EMAIL}"

log() {
    echo "${DATE} - $1" | tee -a "${LOGDIR}/${LOG_FILE}"
}

send_email() {
    echo 'Sending-email notification...'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOG_FILE} successfully."
    cat "${LOGDIR}/${LOG_FILE}" | mailx -s "${EMAIL_SUBJECT}" ${EMAIL}
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

remove_nodejs_path_entries() {
    log 'Aggressively removing all Node.js PATH entries from all profile files and current environment...'

    # List of files to process: user/root plus system-wide
    PROFILE_FILES=(~/.bash_profile ~/.profile ~/.bashrc ~/.zshrc /root/.bash_profile /root/.profile /root/.bashrc /root/.zshrc /etc/profile)
    for f in /etc/profile.d/*; do
        [ -f "$f" ] && PROFILE_FILES+=("$f")
    done

    for PROFILE in "${PROFILE_FILES[@]}"; do
        if [ -f "$PROFILE" ]; then
            cp -p "$PROFILE" "${PROFILE}.bak"
            log "$PROFILE backed up"

            # Remove lines that add node, node-v*, or nodejs bin to PATH (any plausible pattern)
            sed -i '/node-v[0-9]*\.[0-9]*\.[0-9]*-.*\/bin/d' "$PROFILE"
            sed -i '/nodejs\/node-v[0-9]*\.[0-9]*\.[0-9]*-.*\/bin/d' "$PROFILE"
            sed -i '/nodejs\/bin/d' "$PROFILE"
            sed -i '/node\/bin/d' "$PROFILE"
            sed -i '/export PATH=.*nodejs.*\/bin.*:\$PATH/d' "$PROFILE"
            sed -i '/export PATH=.*node-v.*\/bin.*:\$PATH/d' "$PROFILE"
            sed -i '/PATH=.*node-v.*\/bin.*:\$PATH/d' "$PROFILE"
            sed -i '/PATH=.*nodejs.*\/bin.*:\$PATH/d' "$PROFILE"

            log "$PROFILE cleaned of Node.js PATH entries"
        fi
    done

    # Remove Node.js directories from current PATH in this session (runtime only)
    OLD_PATH="$PATH"
    NEW_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "node-v" | grep -v "nodejs" | paste -sd:)
    export PATH="$NEW_PATH"
    log "PATH updated for current shell session (Node.js entries removed)."
    log "Old PATH: $OLD_PATH"
    log "New PATH: $PATH"
}
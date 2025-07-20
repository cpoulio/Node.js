#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail

################################################################################
echo "--------------------Starting Variables_Functions.sh Script--------------------"
################################################################################

MAIN_SCRIPT="main.sh"
deploy_dir="./"  # Local Testing: Comment out when deploying with Ansible.
SCRIPT="${deploy_dir}/${MAIN_SCRIPT}" # Uncomment for Ansible deployment
echo "DEBUG in Main.sh: 'Deployment Directory=>${deploy_dir}'"

################################################################################
VERSION="20.19.2"
NPM_VERSION="10.8.2"

### Variables that Do Not Change Much #####
SOFTWARENAME="NodeJS"
HOSTNAME="$(uname -n)"
INSTALLDIR="/usr/local/lib/nodejs"
LOGDIR="/tmp"
NODE_VERSION="v${VERSION}"
LINUX_DISTRO="linux-x64"
NODEJSFILE="node-${NODE_VERSION}-${LINUX_DISTRO}"
FILEPATH="${INSTALLDIR}/${NODEJSFILE}/bin"
YUM_PACKAGES="openssl-devel bzip2-devel libicu-devel gcc-c++ make"
DATE="$(date "+%Y-%m-%d %H:%M:%S")"

### Check Variables ###
echo "STARTING SCRIPT: ${SOFTWARENAME}"
echo "Deployment Directory=${deploy_dir}"
echo "${NODEJSFILE}"
echo "${FILEPATH}"
echo "${NODE_VERSION}"
echo "DATE=${DATE}"

################################################################################
## Common Functions ############################################################
################################################################################

log() {
  if [[ -z "${LOG_FILE:-}" ]]; then
    echo "ERROR: LOG_FILE is not set!"
    return 1
  fi
  echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "${LOGDIR}/${LOG_FILE}"
}

backup_and_remove_old_paths() {
  log 'Backing up and removing old paths from profile files...'

  # Backup and remove old paths from profiles
  for PROFILE in ~/.bash_profile ~/.profile ~/.bashrc ~/.zshrc; do
    if [[ -f "$PROFILE" ]]; then
      cp "$PROFILE" "${PROFILE}.bak" | tee -a "${LOGDIR}/${LOG_FILE}"
      log "$PROFILE backed up"
      sed -i "s|${INSTALLDIR//\//\\/}/node-v.*/bin/||" $PROFILE
      sed -i "/export PATH=.*${NODE_BIN_DIR//\//\\/}/d" $PROFILE
      log "$PROFILE updated to remove old paths"
    fi
  done
}

remove_nodejs_path_entries() {
  log 'Aggressively removing all Node.js PATH entries from all profile files and current environment...'

  # List of files to process: user/root plus system-wide
  PROFILE_FILES=(~/.bash_profile ~/.profile ~/.bashrc ~/.zshrc /etc/profile.d/*)
  for f in /etc/profile.d/*; do
    [[ -f "$f" ]] && PROFILE_FILES+=("$f")
  done

  for PROFILE in "${PROFILE_FILES[@]}"; do
    if [[ -f "$PROFILE" ]]; then
      cp "$PROFILE" "${PROFILE}.bak"
      log "$PROFILE backed up"

      # Remove lines that add node, node-v*, or nodejs bin to PATH (any plausible pattern)
      sed -i '/nodejs\/node-v[0-9]*\.[0-9]*\.[0-9]*\/bin/d' "$PROFILE"
      sed -i '/\/nodejs\/bin/d' "$PROFILE"
      sed -i '/\/node\/bin/d' "$PROFILE"
      sed -i '/export PATH=.*node-v.*\/bin.*/d' "$PROFILE"
      sed -i '/PATH=.*node-v.*\/bin.*/d' "$PROFILE"
      sed -i '/PATH=.*nodejs.*\/bin.*/d' "$PROFILE"

      log "$PROFILE cleaned of Node.js PATH entries"
    fi
  done

  # Remove Node.js directories from current PATH in this session (runtime only)
  OLD_PATH="$PATH"
  NEW_PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "nodev" | grep -v "nodejs" | paste -sd:)
  export PATH="$NEW_PATH"
  log "PATH updated for current shell session (Node.js entries removed)."
  log "Old PATH: $OLD_PATH"
  log "New PATH: $PATH"
}

show_debug() {
  echo "  ➤ Selected OPTION: ${OPTION}"
  echo "  ➤ Executing: ${SCRIPT} ${FINAL_ARGS}"
  echo "  ➤ DEBUG: FINAL ARGUMENTS TO ${MAIN_SCRIPT}: [${FINAL_ARGS}]"
}

ensure_root() {
  local current_user
  current_user="$(whoami)"
  # If not root and matches npevlttcots* pattern, re-exe script as root
  if [[ "$current_user" != "root" && "$current_user" =~ ^npevlttcots[0-9]+$ ]]; then
    echo "Current user is $current_user, escalating to root for script execution..."
    exec sudo "$0" "$@"
    return 1
  fi
}

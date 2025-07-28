#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail

################################################################################
echo "--------------------Starting Variables_Functions.sh Script--------------------"

MAIN_SCRIPT="main.sh"
deploy_dir="./"  # Local Testing: Comment out when deploying with Ansible.
SCRIPT="${deploy_dir}/${MAIN_SCRIPT}" # Uncomment for Ansible deployment
echo "DEBUG in Main.sh: 'Deployment Directory=>${deploy_dir}'"

################################################################################
VERSION="20.19.2"
NPM_VERSION="10.8.2"

# Exclusions: comma-separated. Example: "action-runner,java,control-m"
EXCLUSION_LIST=${EXCLUSION_LIST:-"actions-runners"}
EXCLUSION_PATTERN=$(echo "$EXCLUSION_LIST" | sed 's/,/|/g')

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
DATE="$(date '+%Y-%m-%d-%H-%M-%S')"

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
send_email() {
    echo 'Sending-email notification...'
    EMAIL_SUBJECT="${HOSTNAME}: ${LOG_FILE} successfully."
    echo "${EMAIL_SUBJECT}" $EMAIL_LIST
    mailx -s "${EMAIL_SUBJECT}" $EMAIL_LIST < "${LOGDIR}/${LOG_FILE}"
}

log() {
  if [[ -z "${LOG_FILE:-}" ]]; then
    echo "ERROR: LOG_FILE is not set!"
    return 1
  fi
  echo "$(date '+%Y-%m-%d-%H-%M-%S') - $1" | tee -a "${LOGDIR}/${LOG_FILE}"
}

# Return latest Verify-related log (case-insensitive match on ACTION_PERFORMED=verify)
get_latest_verify_log() {
  find "$LOGDIR" -type f -iname "*verify*.log" -printf "%T@ %p\n" 2>/dev/null |
    sort -n | tail -1 | cut -d' ' -f2-
}

get_log_file_path() {
  [[ "$LOG_FILE" == /* ]] && echo "$LOG_FILE" || echo "${LOGDIR}/${LOG_FILE}"
}


remove_node_bin_dir_from_profiles() {
    echo "----- Removing Node.js bin directories from all profile files -----"
    # List of profile files to check
    PROFILE_FILES=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "/etc/profile" /etc/profile.d/*)
    
    # Find all bin dirs ever referenced (from standard installs)
    NODE_BIN_DIRS=(
        "/usr/local/lib/nodejs/node-v"*"-linux-x64/bin"
        "/usr/local/lib/nodejs/node-v"*"/bin"
        "/usr/local/bin"
    )

    # Expand wildcards and remove duplicates
    ALL_NODE_BINS=$(ls -d ${NODE_BIN_DIRS[@]} 2>/dev/null | sort -u)

    for PROFILE in "${PROFILE_FILES[@]}"; do
        [[ -f "$PROFILE" ]] || continue
        for BIN_DIR in $ALL_NODE_BINS; do
            # Escape slashes for sed
            BIN_ESCAPED=$(echo "$BIN_DIR" | sed 's:/:\\/:g')
            # Find and show matching lines
            grep -F "export PATH=$BIN_DIR:\$PATH" "$PROFILE" && \
                echo "Removing from $PROFILE: export PATH=$BIN_DIR:\$PATH"
            # Remove the lines
            sed -i "/export PATH=${BIN_ESCAPED}:\$PATH/d" "$PROFILE"
        done
    done
    echo "----- Done cleaning profile files -----"
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

#!/bin/bash
#set -x
shopt -s extglob
set -euxo pipefail
#################################################################################

echo "-------------------Starting Uninstall.sh Script----------------------------"

source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
source ./verify.sh && echo 'Sourced: verify.sh'
echo "Starting Uninstall Script"
ensure_root "$@"

uninstall(){
  log "Starting Uninstall ${SOFTWARENAME} Function"
  ACTION_PERFORMED="Uninstall"
  LOG_FILE="${NODE_VERSION}-${LINUX_DISTRO}-${ACTION_PERFORMED}-${DATE}.log"

  #Remove only the installed version
  if [ -d "${INSTALLDIR}/${NODEJSFILE}" ]; then
    rm -rf "${INSTALLDIR}/${NODEJSFILE}" && log "${SOFTWARENAME} ${NODEJSFILE} directory removed."
  else
    log "${SOFTWARENAME} ${NODEJSFILE} directory not found."
  fi

  # Remove symlinks only if they point to our installation
  for bin in node npm npx; do
    BIN_PATH="/usr/local/bin/$bin"
    if [ -L "$BIN_PATH" ]; then
      TARGET=$(readlink "$BIN_PATH")
      if [[ "$TARGET" == "${INSTALLDIR}/${NODEJSFILE}/bin/$bin" ]]; then
        rm -f "$BIN_PATH" && log "$bin symlink removed from /usr/local/bin"
      fi
    fi
  done

  remove_nodejs_path_entries

  backup_and_remove_old_paths

  log "${SOFTWARENAME} safely removed"
  log "Uninstall Completed."

  log "Running verify"
  verify
  send_email
}

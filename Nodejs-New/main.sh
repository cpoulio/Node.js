#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail

##################################################################
echo "------------------Starting Main.sh Script---------------------"
EMAIL=""
EMAIL_LIST=""
source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
echo "DEBUG in Main.sh: Deployment Directory=${deploy_dir}"
result="$(ensure_root)"
echo "$result"

##################################################################
# Parse command-line arguments (OPTION can also be set via env)
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --option)
        OPTION="$2"
        shift 2
        ;;
      --email)
        if [[ -n "$2" ]]; then
          EMAIL="$2"
          shift 2
        fi
        ;;
      *)
        echo "X Invalid argument: $1"
        return 1
        ;;
    esac
  done
}

parse_args "$@"

# If OPTION is still not set, default to verify
OPTION="${OPTION:-verify}"

echo "STARTING SCRIPT: ${SOFTWARENAME}"
echo "Deployment Directory=${deploy_dir}"
echo "${NODEJSFILE}"
echo "${FILEPATH}"
echo "${NODE_VERSION}"
echo "Date=$(date)"
echo "${EMAIL_LIST}"
echo "ARGS: $@"
echo "DEBUG: OPTION is ${OPTION}"

email_list () {
  echo "Set EMAIL_LIST after extracting --email"
  EMAIL_LIST="christopher.g.pouliot@irs.gov"
  if [[ -n "$EMAIL" ]]; then
    EMAIL_LIST="$EMAIL"
  fi
  echo "  * Executing: ${EMAIL_LIST}"
}
email_list

ls -la

##################################################################
# Main Execution Logic
##################################################################
case ${OPTION} in
  install)
    source ./install.sh
    install "$@"
    ;;
  uninstall)
    source ./uninstall.sh
    uninstall "$@"
    ;;
  verify)
    source ./verify.sh
    verify "$@"
    ;;
  uninstall_all)
    source ./uninstall_all.sh
    uninstall_all "$@"
    ;;
  uninstall_from_verify)
    source ./uninstall_from_verify.sh
    uninstall_from_verify "$@"
    ;;
  update)
    source ./update.sh
    update "$@"
    ;;
  update_after_uninstall_from_verify)
    source ./update_after_uninstall_from_verify.sh
    update_after_uninstall_from_verify "$@"
    ;;
  *) echo "X Invalid option: $OPTION" ; exit 1 ;;
esac
echo "DEBUG: OPTION is ${OPTION}"
# (Do not call send_email here, handled in install/uninstall/verify scripts)

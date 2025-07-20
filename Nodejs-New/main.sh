#!/bin/bash
#set -x
shopt -s extglob
set -euo pipefail

##################################################################
# Source Scripts you need
echo "------------------Starting Main.sh Script---------------------"
EMAIL=""
EMAIL_LIST=""
source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'
echo "DEBUG in Main.sh: Deployment Directory=${deploy_dir}"
ensure_root "$@"
result="$(ensure_root)"
echo "$result"
e9 "$(ensure_root)"

##################################################################
### Source scripts
##################################################################

### Check Variables ##############################################
email_list () {
  echo "Set EMAIL_LIST after extracting --email"
  EMAIL_LIST="christopher.g.pouliot@irs.gov"
  # Append provided --email to EMAIL_LIST if it exists
  if [[ -n "$EMAIL" ]]; then
    EMAIL_LIST="$EMAIL"
  fi
  echo "  * Executing: ${EMAIL_LIST}"
}

send_email() {
  echo "Sending-email notification..."
  EMAIL_SUBJECT="$(hostname): ${LOG_FILE} successfully."
  echo "* EMAIL_SUBJECT=${EMAIL_SUBJECT}; ${EMAIL_LIST}"
  echo "* DEBUG: FINAL EMAIL LIST BEFORE MAILX: [${EMAIL_LIST}]"
  mailx -s "${EMAIL_SUBJECT}" ${EMAIL_LIST} < "${LOGDIR}/${LOG_FILE}"

  echo "*${EMAIL_LIST}"
}

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

##################################################################
## Check Variables ###############################################
##################################################################
parse_args "$@"
echo "$(parse_args)"

echo "STARTING SCRIPT: ${SOFTWARENAME}"
echo "Deployment Directory=${deploy_dir}"
echo "${NODEJSFILE}"
echo "${FILEPATH}"
echo "${NODE_VERSION}"
echo "Date=$(date)"
echo "${EMAIL_LIST}"
echo "ARGS: $@"
echo "DEBUG: OPTION is ${OPTION}"

email_list
echo "$(email_list)"

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
  update_afte_uninstall_from_verify)
    source ./update_after_uninstall_from_verify.sh
    update_afte_uninstall_from_verify "$@"
    ;;
  *) echo "X Invalid option: $OPTION" ; exit 1 ;;
esac
echo "DEBUG: OPTION is ${OPTION}"
send_email

#!/bin/bash
set -x

#########################################
# Source scripts
#########################################

# Source Each Script
source ./variables_functions.sh && echo 'Sourced: variables_functions.sh'


# Or use a for loop to import all and choose dir.
# for script in ./scripts/*.sh; do
#     if source "$script"; then
#         echo "[INFO:] Sourced: $script"
#     else
#         echo "[ERROR:] Failed to source: $script"
#         exit 1
#     fi
# done

# Check Variables
echo "STARTING SCRIPT: ${SOFTWARENAME}"
echo "Deployment Directory: ${deploy_dir}"
echo "${NODEJSFILE}"
echo "${FILEPATH}"
echo "${NODE_VERSION}"
echo "DATE=$(DATE)"
echo "${EMAIL}"

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
      echo "✘ Invalid argument: $1"
      exit 1
      ;;
  esac
done

# Ensure OPTION is set (default to install if missing)
validate_and_set_option

# Set EMAIL_LIST after extracting --email
EMAIL_LIST='christopher.g.pouliot@irs.gov'
# Append provided --email to EMAIL_LIST if it exists
if [[ -n "$EMAIL" ]]; then
  EMAIL_LIST="$EMAIL"
fi

echo "➤ Executing: [${EMAIL_LIST}]"
echo "DEBUG: OPTION is '$OPTION'"

#########################################
# Main Execution Logic
#########################################

case ${OPTION} in
  install)
    source ./install.sh
    install
    ;;
  uninstall)
    source ./uninstall.sh
    uninstall
    ;;
  uninstall_all)
    source ./uninstall_all.sh
    uninstall_all
    ;;
  upgrade)
    source ./upgrade.sh
    upgrade
    ;;
  verify)
    source ./verify.sh
    verify
    ;;
  uninstall_from_verify)
    source ./uninstall_from_verify.sh
    uninstall_from_verify
    ;;
  *)
    echo "✘ Invalid option. Usage: OPTION=(install|uninstall|uninstall_all|upgrade|verify|uninstall_from_verify)" ; exit 1 ;;
esac

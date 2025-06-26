#!/bin/bash
set -x

#########################################
# Source scripts
#########################################

# Source Each Script
source ./install.sh && echo 'Sourced: install.sh'
source ./uninstall.sh && echo 'Sourced: uninstall.sh'
source ./uninstall_all.sh && echo 'Sourced: uninstall_all.sh'
source ./upgrade.sh && echo 'Sourced: upgrade.sh'
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
if [[ -z "${OPTION}" ]]; then
  echo "✘ Error: --option is required."
  exit 1
fi

# Ensure only valid options are accepted
if [[ ! "${OPTION}" =~ ^(install|uninstall|uninstall_all|upgrade)$ ]]; then
  echo "✘ Invalid OPTION: ${OPTION}. Use --option install, uninstall, uninstall_all, or update."
  exit 1
fi

# Set EMAIL_LIST after extracting --email
EMAIL_LIST='christopher.g.pouliot@irs.gov'
# Append provided --email to EMAIL_LIST if it exists
if [[ -n "$EMAIL" ]]; then
  EMAIL_LIST="$EMAIL"
fi

echo "➤ Executing: [${EMAIL_LIST}]"

#########################################
# Main Execution Logic
#########################################

case ${OPTION} in
  install) install ;;
  uninstall) uninstall ;;
  uninstall_all) uninstall_all ;;
  upgrade) upgrade ;;
  *)
    echo "✘ Invalid option. Usage: OPTION=(install|uninstall|uninstall_all|update)"; exit 1 ;;
esac

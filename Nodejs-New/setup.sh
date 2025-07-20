#!/bin/bash
# shellcheck disable=SC1091
set -x
shopt -s extglob
set -euo pipefail

################################################################################
echo "-------------------- Starting Setup.SH Script --------------------"
source ./variables_functions.sh && echo "Sourced: variables_functions.sh"
echo "DEBUG in Setup.SH: Deployment Directory=${deploy_dir}"
echo "Starting Setup Script"
EMAIL=""
ensure_root "$@"
result=$(ensure_root)
echo "$result"
################################################################################

validate_option() {
  # Validate OPTION value
  if [[ ! "${OPTION}" =~ ^(install|uninstall|uninstall_all|uninstall_from_verify|update|update_afte_uninstall_from_verify|verify)$ ]]; then
    echo "X Invalid OPTION: ${OPTION}. Use --option install, uninstall, uninstall_all, uninstall_from_verify, update, update_afte_uninstall_from_verify, verify."
    return 1
  fi
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

# Path to the main script
#deploy_dir='/opt/actions-runner/binaries' # Use for GitHub Actions, Comment out when deploying with Ansible.

# Extract command-line arguments
parse_args "$@"

# Double Ensure OPTION is set, default to install
OPTION="${OPTION-verify}"
if [[ -z "$OPTION" ]]; then
  OPTION="verify"
fi

# Ensure only valid options are accepted
validate_option
echo "OPTION=${OPTION}" # Debugging

# Build FINAL_ARGS
FINAL_ARGS="--option $OPTION"
if [[ -n "$EMAIL" ]]; then
  FINAL_ARGS+=" --email $EMAIL"
fi

echo "Debugging: Print the final command before executing"
echo "  > Executing: ${SCRIPT} ${FINAL_ARGS}"

echo "${NODESJFILE}"
echo "${FILEPATH}"
echo "${NODE_VERSION}"
echo "DATE=${DATE}"
echo "${EMAIL}"
echo "ARGS: $@"

echo "STARTING SCRIPT: ${SOFTWARENAME}"
echo "Deployment Directory=${deploy_dir}"
echo "ARGS: $@"
echo "DEBUG: FINAL ARG is: $FINAL_ARGS"
echo "DEBUG: OPTION is $OPTION"
echo " > DEBUG: Executing: ${SCRIPT} ${FINAL_ARGS}"

# Execute the script only once
exec "${SCRIPT}" ${FINAL_ARGS}
show_debug
echo "✅ ${SCRIPT} setup script executed successfully!"

#!/bin/bash
set -x
shopt -s extglob
set -euo pipefail

################################################################################
echo "-------------------- Starting Setup.sh Script --------------------"
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
  if [[ ! "${OPTION}" =~ ^(install|uninstall|uninstall_all|uninstall_from_verify|update|update_after_uninstall_from_verify|verify)$ ]]; then
    echo "X Invalid OPTION: ${OPTION}. Use --option install, uninstall, uninstall_all, uninstall_from_verify, update, update_after_uninstall_from_verify, verify."
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

# Extract command-line arguments (can also get OPTION from env)
parse_args "$@"

# Double Ensure OPTION is set, default to verify if not present
OPTION="${OPTION:-${OPTION:-verify}}"
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

# Export for downstream scripts (important!)
export OPTION
export EMAIL

echo "Debugging: Print the final command before executing"
echo "  > Executing: ${SCRIPT} ${FINAL_ARGS}"

echo "${NODEJSFILE}"
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

# Execute the main script
exec "${SCRIPT}" ${FINAL_ARGS}

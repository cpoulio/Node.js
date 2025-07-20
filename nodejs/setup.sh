#!/bin/bash
set -x

## This script sets up the environment and runs the main Node.js management script with the provided options
# It ensures that all necessary variables are defined and that the correct options are passed to the main script
# The script is designed to be flexible and can be used in various deployment scenarios, including local testing and Ansible deployments
# It also includes functions for logging, sending email notifications, and managing Node.js installations
# The script is modular, allowing for easy updates and maintenance of the Node.js environment
# It is intended to be run in a Linux environment and assumes that the necessary dependencies

# --- Functions used only in this script ---
# (If any of these are used in other scripts, keep them in variables_functions.sh instead)

ensure_root() {
  local current_user
  current_user="$(whoami)"
  if [[ "$current_user" != "root" && "$current_user" =~ ^npevlttcots[0-9]+$ ]]; then
    echo "Current user is $current_user, escalating to root for script execution..."
    exec sudo "$0" "$@"
    exit 1
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
        EMAIL="$2"
        shift 2
        ;;
      *)
        echo "✘ Invalid argument: $1"
        exit 1
        ;;
    esac
  done
}

validate_and_set_option() {
  OPTION="${OPTION:-verify}"
  if [[ -z "${OPTION}" ]]; then
    echo "✘ Error: --option is required."
    exit 1
  fi
  if [[ ! "${OPTION}" =~ ^(install|uninstall|uninstall_all|upgrade|verify|uninstall_from_verify)$ ]]; then
    echo "✘ Invalid OPTION: ${OPTION}. Use --option install, uninstall, uninstall_all, upgrade, verify, or uninstall_from_verify."
    exit 1
  fi
}

build_final_args() {
  FINAL_ARGS="--option $OPTION"
  if [[ -n "$EMAIL" ]]; then
    FINAL_ARGS+=" --email $EMAIL"
  fi
}

show_debug() {
  echo "➤ Selected OPTION: ${OPTION}"
  echo "➤ Executing: ${SCRIPT} ${FINAL_ARGS}"
  echo "➤ DEBUG: FINAL ARGUMENTS TO ${MAIN_SCRIPT}: [${FINAL_ARGS}]"
}
# --- End of local functions ---

# Source shared variables and functions
source ./variables_functions.sh

# Set the main script to call
MAIN_SCRIPT="main.sh"
deploy_dir="."
SCRIPT="${deploy_dir}/${MAIN_SCRIPT}"

# Parse and process arguments and variables
parse_args "$@"
validate_and_set_option
build_final_args
show_debug

# Run the main script with correctly formatted arguments
echo "Executing: ${SCRIPT} ${FINAL_ARGS}"
${SCRIPT} ${FINAL_ARGS}
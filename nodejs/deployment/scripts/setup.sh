#!/bin/bash
set -x
#########################################
MAIN_SCRIPT="main.sh"

# Path to the main script
#SCRIPT="${deploy_dir}/${MAIN_SCRIPT}"   # For Ansible deployment
SCRIPT="./${MAIN_SCRIPT}"               # Uncomment for local testing

# Extract command-line arguments
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

# Ensure OPTION is set, default to install
OPTION="${OPTION:-install}"

# Ensure OPTION is set (default to install if missing)
if [[ -z "${OPTION}" ]]; then
    OPTION="install"
fi
echo "➤ Selected OPTION: ${OPTION}"

# Ensure only valid options are accepted
if [[ ! "${OPTION}" =~ ^(install|uninstall|uninstall_all|upgrade)$ ]]; then
  echo "✘ Invalid OPTION: ${OPTION}. Use --option install, uninstall, uninstall_all, or update."
  exit 1
fi

# Build FINAL_ARGS
FINAL_ARGS="--option $OPTION"
if [[ -n "$EMAIL" ]]; then
  FINAL_ARGS+=" --email $EMAIL"
fi

# Debugging: Show the exact command being executed
echo "➤ Executing: ${SCRIPT} ${FINAL_ARGS}"
echo "➤ DEBUG: FINAL ARGUMENTS TO ${MAIN_SCRIPT}: [${FINAL_ARGS}]"

# Run the main script with correctly formatted arguments
${SCRIPT} ${FINAL_ARGS}

echo "✅ ${MAIN_SCRIPT} setup script executed successfully!"

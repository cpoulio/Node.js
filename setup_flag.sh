#!/bin/bash

###############################################################################################################
# Description:
# This script processes arguments for NodeJS installation and activation. It supports:
# - Named flags (`--mode`, `--email`, etc.)
# - Environment variables (e.g., `MODE=install EMAIL=admin@example.com`)
# - Multi-word values
# - Case insensitivity
# - Default values when arguments are missing
# - Put arguments in any order
#
# ✅ Supports:
# MODE=install ./setup_nodejs.sh
# ./setup_nodejs.sh --mode install
# ./setup_nodejs.sh --mode uninstall
# ./setup_nodejs.sh --mode update
# ./setup_nodejs.sh --mode install --email admin@example.com
###############################################################################################################

# Define expected flags (uppercase)
EXPECTED_FLAGS="MODE,EMAIL"

# If MODE is not set, default to "install"
if [[ -z "${MODE}" ]]; then  
    MODE="install"
fi

# Path to the main script
SCRIPT="${deploy_dir}/NodeJS.sh"  # For Ansible deployment
#SCRIPT="./NodeJS.sh"  # Uncomment for local testing

# --------------------------------------------
# FUNCTION: Parse Arguments & Convert `KEY=VALUE` to Flags
# --------------------------------------------
parse_and_convert_args() {
    FLAGS=""

    # Convert comma-separated list into an array
    IFS=',' read -ra VARS <<< "$EXPECTED_FLAGS"
    
    for VAR in "${VARS[@]}"; do
        VALUE="${!VAR}"  # Get the value of the environment variable
        if [[ -n "$VALUE" ]]; then
            FLAG_NAME="--$(echo "$VAR" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"
            FLAGS+=" $FLAG_NAME \"$VALUE\""
        fi
    done

    # If --mode is missing, explicitly add --mode install
    if [[ ! "$FLAGS" =~ "--mode" ]]; then
        FLAGS="--mode install $FLAGS"
    fi

    echo "$FLAGS"
}

# Convert both KEY=VALUE environment variables AND manual flags
ARG_FLAGS=$(parse_and_convert_args)
FINAL_ARGS="$ARG_FLAGS $*"

# Debugging: Print the final command before executing
echo "Executing command: ${SCRIPT} ${FINAL_ARGS}"

# Execute the script correctly
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

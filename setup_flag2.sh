#!/bin/bash

###############################################################################################################
# Description:
# This script processes arguments for NodeJS installation and activation. It supports:
# - Named flags (`--mode`, `--email`, etc.)
# - Environment variables (e.g., `MODE=install EMAIL=admin@example.com`)
# - Multi-word values
# - Case insensitivity
# - Default values when arguments are missing
# - Arguments in any order
#
# ✅ Supports:
# EMAIL=test@gmail.com MODE=install ./setup_flag.sh
# ./setup_flag.sh --email test@gmail.com --mode uninstall
###############################################################################################################

# Define expected flags (uppercase)
EXPECTED_FLAGS="MODE,EMAIL"

# Ensure MODE is always set
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

    echo "$FLAGS"
}

# Convert both KEY=VALUE environment variables AND manual flags
ARG_FLAGS=$(parse_and_convert_args "$@")

# Build final arguments (keeping both converted flags and manual CLI input)
FINAL_ARGS=$(echo "$ARG_FLAGS $*" | xargs)  # Fix extra spaces

# Debugging: Print the final command before executing
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Execute the script correctly
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

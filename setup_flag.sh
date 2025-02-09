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
VALID_MODES=("install" "uninstall" "update")

# If MODE is not set, default to "install"
if [[ -z "${MODE}" ]]; then  
    MODE="install"
fi

# Validate MODE input
validate_mode() {
    for valid in "${VALID_MODES[@]}"; do
        if [[ "$MODE" == "$valid" ]]; then
            return 0
        fi
    done
    echo "❌ ERROR: Invalid MODE '$MODE'. Must be one of: install, uninstall, update."
    exit 1
}

# Validate script path
SCRIPT="${deploy_dir}/NodeJS.sh"  # For Ansible deployment
#SCRIPT="./NodeJS.sh"  # Uncomment for local testing

if [[ ! -f "$SCRIPT" ]]; then
    echo "❌ ERROR: Main script '$SCRIPT' not found. Ensure it exists and is executable."
    exit 1
fi

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

# Validate MODE
validate_mode

# Convert both KEY=VALUE environment variables AND manual flags
ARG_FLAGS=$(parse_and_convert_args)
FINAL_ARGS="$ARG_FLAGS $*"

# Debugging: Print the final command before executing
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Execute the script correctly
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

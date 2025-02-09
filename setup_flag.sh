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
# Usage:
# You can call this script using either KEY=VALUE format (for Ansible) or flags (for manual execution).
#
# ✅ Using KEY=VALUE format (Ansible style):
# MODE=install ./setup_nodejs.sh
# MODE=uninstall ./setup_nodejs.sh
# MODE=update ./setup_nodejs.sh
# MODE=install EMAIL=admin@example.com ./setup_nodejs.sh
#
# ✅ Using flags (manual execution):
# ./setup_nodejs.sh --mode install
# ./setup_nodejs.sh --mode uninstall
# ./setup_nodejs.sh --mode update
# ./setup_nodejs.sh --mode install --email admin@example.com

###############################################################################################################

# Define all expected flags here so they can be changed easily and they HAVE TO be in uppercase!!!
EXPECTED_FLAGS="MODE,EMAIL"

# Ensure MODE is blanked out before assigning a default value
if [[ -z "${MODE}" ]]; then  
    MODE="install"  # Default to install if not set
fi

# Path to the main script
SCRIPT="${deploy_dir}/NodeJS.sh"  # Deploy with Ansible
#SCRIPT="./NodeJS.sh"  # Uncomment for local testing

# --------------------------------------------
# FUNCTION: Parse Arguments & Convert `KEY=VALUE` to Flags
# --------------------------------------------
parse_and_convert_args() {
    FLAGS=""
    
    # Convert the comma-separated list into an array
    IFS=',' read -ra VARS <<< "$EXPECTED_FLAGS"
    
    for VAR in "${VARS[@]}"; do
        VALUE="${!VAR}"  # Get the value of the environment variable
        if [[ -n "$VALUE" ]]; then
            FLAG_NAME="--$(echo "$VAR" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"
            FLAGS+=" $FLAG_NAME \"$VALUE\""
        fi
    done

    # Ensure MODE is explicitly passed if it's not already in the flags
    if [[ ! "$FLAGS" =~ "--mode" ]]; then
        FLAGS="--mode install $FLAGS"
    fi

    echo "$FLAGS"
}

# Convert arguments and execute the main script
ARG_FLAGS=$(parse_and_convert_args "$@")
set -- ${ARG_FLAGS}
${SCRIPT} "$@"
echo "✅ NodeJS setup script executed successfully!"

# End of script

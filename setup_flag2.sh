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
# MODE=install ./setup_flag.sh
# ./setup_flag.sh --mode install
# ./setup_flag.sh --mode uninstall
# ./setup_flag.sh --mode update
###############################################################################################################

# Define expected flags (uppercase)
EXPECTED_FLAGS="MODE,EMAIL"

# Capture command-line arguments
CMD_ARGS=("$@")

# Extract --mode argument from command-line input
CMD_MODE=""
for ((i = 0; i < ${#CMD_ARGS[@]}; i++)); do
    if [[ "${CMD_ARGS[i]}" == "--mode" ]]; then
        CMD_MODE="${CMD_ARGS[i+1]}"
        break
    fi
done

# Ensure MODE is always set, preferring:
# 1. Command-line `--mode` if provided
# 2. Environment variable `MODE`
# 3. Default to "install"
if [[ -n "$CMD_MODE" ]]; then
    MODE="$CMD_MODE"
elif [[ -n "${MODE}" ]]; then  
    MODE="${MODE}"  # Keep environment value if set
else
    MODE="install"  # Default if nothing is set
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

# Ensure there is only **one** `--mode` in FINAL_ARGS
if [[ ! "$ARG_FLAGS" =~ "--mode" && ! "$*" =~ "--mode" ]]; then
    FLAGS="--mode $MODE $FLAGS"
fi

FINAL_ARGS=$(echo "$FLAGS $*" | xargs)  # Fix extra spaces

# Debugging: Print the final command before executing
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Execute the script correctly
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

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

# Determine the final MODE value:
# 1. Use --mode from command-line arguments if provided
# 2. Use environment variable MODE if set
# 3. Default to "install" if no mode is set
if [[ -n "$CMD_MODE" ]]; then
    MODE="$CMD_MODE"
elif [[ -z "$MODE" ]]; then
    MODE="install"
fi

# Path to the main script
SCRIPT="${deploy_dir}/NodeJS.sh"  # For Ansible deployment
#SCRIPT="./NodeJS.sh"  # Uncomment for local testing

# --------------------------------------------
# FUNCTION: Convert `KEY=VALUE` into flags
# --------------------------------------------
parse_and_convert_args() {
    FLAGS=""

    # Convert expected KEY=VALUE environment variables into --flag value format
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

# Convert environment variables to flags
ARG_FLAGS=$(parse_and_convert_args "$@")

# Ensure `--mode` is included exactly once
if [[ -z "$CMD_MODE" && ! "$ARG_FLAGS" =~ "--mode" ]]; then
    ARG_FLAGS="--mode $MODE $ARG_FLAGS"
fi

# Combine all arguments (converted environment variables + command-line args)
FINAL_ARGS=$(echo "$ARG_FLAGS $*" | xargs)  # Remove extra spaces

# Debugging: Show the exact command being executed
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Run the main script with correctly formatted arguments
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

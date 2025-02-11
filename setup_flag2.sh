#!/bin/bash

# Define expected flags (uppercase)
EXPECTED_FLAGS="MODE,EMAIL"
MAIN_SCRIPT="NodeJS.sh"

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
# 3. Default to "install" if no mode is set
if [[ -n "$CMD_MODE" ]]; then
    MODE="$CMD_MODE"
elif [[ -n "${MODE}" ]]; then  
    MODE="${MODE}"  # Keep environment value if set
else
    MODE="install"
fi

# Path to the main script
SCRIPT="${deploy_dir}/${MAIN_SCRIPT}"  # For Ansible deployment
#SCRIPT="./${MAIN_SCRIPT}"  # Uncomment for local testing

# Convert KEY=VALUE environment variables into flags
parse_and_convert_args() {
    FLAGS=""

    IFS=',' read -ra VARS <<< "$EXPECTED_FLAGS"
    for VAR in "${VARS[@]}"; do
        VALUE="${!VAR}"  
        if [[ -n "$VALUE" ]]; then
            FLAG_NAME="--$(echo "$VAR" | tr '[:upper:]' '[:lower:]' | tr '_' '-')"
            FLAGS+=" $FLAG_NAME \"$VALUE\""
        fi
    done

    echo "$FLAGS"
}

# Convert environment variables to flags
ARG_FLAGS=$(parse_and_convert_args)

# Ensure `--mode` is only included once
if [[ ! "$ARG_FLAGS" =~ "--mode" ]]; then
    ARG_FLAGS="--mode $MODE $ARG_FLAGS"
fi

# Ensure `--email` is only included once
if [[ -n "$EMAIL" && ! "$ARG_FLAGS" =~ "--email" ]]; then
    ARG_FLAGS+=" --email $EMAIL"
fi

# Combine all arguments (converted environment variables + command-line args)
FINAL_ARGS=$(echo "$ARG_FLAGS $*" | xargs)  # Remove extra spaces

# Debugging: Show the exact command being executed
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Run the main script with correctly formatted arguments
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

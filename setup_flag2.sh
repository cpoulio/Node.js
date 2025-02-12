#!/bin/bash

###############################################################################################################
MAIN_SCRIPT="NodeJS.sh"

# Path to the main script
SCRIPT="${deploy_dir}/${MAIN_SCRIPT}"  # For Ansible deployment
#SCRIPT="./${MAIN_SCRIPT}"  # Uncomment for local testing

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

# Extract command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --email)
            if [[ -n "$2" ]]; then
                EMAIL="$2"
                shift 2
            fi
            ;;
        *)
            echo "❌ Invalid argument: $1"
            exit 1
            ;;
    esac
done

# Ensure MODE is set, default to install
if [[ -z "$MODE" ]]; then
    MODE="install"
fi

# Build FINAL_ARGS
FINAL_ARGS="--mode $MODE"
if [[ -n "$EMAIL" ]]; then
    FINAL_ARGS+=" --email $EMAIL"
fi

# Debugging: Print the final command before executing
echo "🔹 Executing: ./$MAIN_SCRIPT $FINAL_ARGS"

# Execute the script
./$MAIN_SCRIPT $FINAL_ARGS

# Debugging: Show the exact command being executed
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"
echo "🔹 DEBUG: FINAL ARGUMENTS TO NODEJS.SH: [$ARG_FLAGS]"
# Run the main script with correctly formatted arguments
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"

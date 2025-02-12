#!/bin/bash
#set -x
###############################################################################################################

# Define main script name
MAIN_SCRIPT="NodeJS.sh"

SCRIPT="./${MAIN_SCRIPT}"  # Adjust for deployment if needed
#SCRIPT="./${MAIN_SCRIPT}"  # Uncomment for local testing

# Function to capture multi-word values
capture_value() {
    local VAR_NAME=$1
    shift
    if [[ -n "$1" && "$1" != --* ]]; then
        local VALUE="$1"
        shift
        while [[ -n "$1" && "$1" != --* ]]; do
            VALUE+=" $1"
            shift
        done
        eval "$VAR_NAME=\"\$VALUE\""
    fi
}

# Capture command-line arguments
CMD_MODE=""
CMD_ARGS=("$@")

# Parse Additional Arguments (Case-Insensitive)
while [[ $# -gt 0 ]]; do
    ARG="${1,,}"  # Convert argument to lowercase for case insensitivity
    case "$ARG" in
        --mode)
            capture_value CMD_MODE "$@"
            shift
            ;;
        --email)
            capture_value EMAIL "$@"
            shift
            ;;
        *)
            echo "❌ Invalid option: $1"
            echo "Usage: $0 --mode {install|uninstall|update} [--email <email>]"
            exit 1
            ;;
    esac
done

# Ensure MODE is set, default to install
if [[ -z "$CMD_MODE" ]]; then
    CMD_MODE="install"
fi
echo "🔹 DEBUG: FINAL ARGUMENTS TO NODEJS.SH: [$CMD_MODE]"

# Build FINAL_ARGS
FINAL_ARGS="--mode $CMD_MODE"
if [[ -n "$EMAIL" ]]; then
    FINAL_ARGS+=" --email $EMAIL"
fi

# Debugging: Print the final command before executing
echo "🔹 Executing: ./$MAIN_SCRIPT $FINAL_ARGS"


# Debugging: Show the exact command being executed
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Run the main script with correctly formatted arguments
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"
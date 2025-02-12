#!/bin/bash
set -x
###############################################################################################################

# Define main script name
MAIN_SCRIPT="NodeJS.sh"

SCRIPT="./${MAIN_SCRIPT}"  # Adjust for deployment if needed
#SCRIPT="./${MAIN_SCRIPT}"  # Uncomment for local testing

capture_value() {
    local VAR_NAME=$1
    shift
    if [[ -n "$1" && "$1" != --* ]]; then
        eval "$VAR_NAME=\"$1\""  # ✅ Set variable correctly
        shift
        while [[ -n "$1" && "$1" != --* ]]; do
            eval "$VAR_NAME+=\" $1\""
            shift
        done
    else
        echo "❌ Missing value for $VAR_NAME"
        exit 1
    fi
}

# Parse Additional Arguments (Case-Insensitive)
while [[ $# -gt 0 ]]; do
    ARG="${1,,}"  # Convert argument to lowercase for case insensitivity
    case "$ARG" in
        --mode)
            capture_value CMD_MODE "$@"
            ;;
        --email)
            capture_value EMAIL "$@"
            ;;
        *)
            echo "❌ Invalid option: $1"
            echo "Usage: $0 --mode {install|uninstall|update} [--email <email>]"
            exit 1
            ;;
    esac
done

# Ensure MODE is set in the correct order:
# 1️⃣ Use `--mode` from command-line if provided
# 2️⃣ Use `MODE` from environment if set
# 3️⃣ Default to `install` if neither is set
if [[ -n "$CMD_MODE" ]]; then
    MODE="$CMD_MODE"
elif [[ -n "$MODE" ]]; then
    MODE="$MODE"  # Keep the environment value
else
    MODE="install"
fi

# Ensure CMD_MODE is set before building FINAL_ARGS
if [[ -z "$CMD_MODE" ]]; then
    echo "❌ Error: MODE is missing. Use --mode install, uninstall, or update."
    exit 1
fi

# Build FINAL_ARGS only if CMD_MODE has a value
FINAL_ARGS=""
if [[ -n "$CMD_MODE" ]]; then
    FINAL_ARGS="--mode $CMD_MODE"
fi
if [[ -n "$EMAIL" ]]; then
    FINAL_ARGS+=" --email $EMAIL"
fi
# Debugging: Show the exact command being executed
echo "🔹 Executing: ${SCRIPT} ${FINAL_ARGS}"

# Run the main script with correctly formatted arguments
set -- ${FINAL_ARGS}
${SCRIPT} "$@"

echo "✅ NodeJS setup script executed successfully!"
# Function to capture multi-word values
capture_value() {
    local VAR_NAME=$1
    shift
    eval "$VAR_NAME=\"$1\""
    shift
    while [[ $# -gt 0 && "$1" != --* ]]; do
        eval "$VAR_NAME+= \" $1\""
        shift
    done
}
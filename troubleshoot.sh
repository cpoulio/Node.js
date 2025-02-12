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

# Parse Additional Arguments
while [[ $# -gt 0 ]]; do
    ARG="${1,,}"  # Convert argument to lowercase for case insensitivity
    case "$ARG" in
        --email|-e)
            capture_value EMAIL "$@"
            shift
            ;;
        --mode|-m)
            capture_value MODE "$@"
            shift
            ;;
        --om-server)
            capture_value OM_SERVER "$@"
            shift
            ;;
        --cert-server)
            capture_value CERT_SERVER "$@"
            shift
            ;;
        *)
            echo "Invalid option: $1"
            echo "Usage: $0 --mode {install|uninstall|activate|install_and_activate} [--email <email>] [--om-server <server>] [--cert-server <server>]"
            exit 1
            ;;
    esac
done

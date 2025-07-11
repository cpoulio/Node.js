#!/bin/bash
set -x

# This script sets up the environment and runs the main Node.js management script with the provided options
# It ensures that all necessary variables are defined and that the correct options are passed to the main script
# The script is designed to be flexible and can be used in various deployment scenarios, including local testing and Ansible deployments
# It also includes functions for logging, sending email notifications, and managing Node.js installations
# The script is modular, allowing for easy updates and maintenance of the Node.js environment
# It is intended to be run in a Linux environment and assumes that the necessary dependencies
# Source shared variables and functions

source ./variables_functions.sh
setup "$@"
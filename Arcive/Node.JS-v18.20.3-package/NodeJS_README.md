# NodeJS.sh ReadMe!
## How to Install

- Place the NodeJS18.tar.xz and the license file in the script's directory.
- Run the script locally with the install argument:
    `./NodeJS.sh install`

- Run the script with setup.sh, install is default and does not need an argument:
    `./setup.sh`

## How to Uninstall

- Run the script with the uninstall argument:
    `./NodeJS.sh uninstall`

- Run the script with setup.sh, uninstall is default and does not need an argument:
    `MODE=uninstall ./setup.sh`

### Install Mode:
1. Install required YUM packages.
2. Extract NodeJS from the tarball.
3. Update the .bash_profile to set the environment path.
4. Establish symbolic links for NodeJS binaries.
5. Verify the NodeJS and npm installations.
6. Send a completion email with the installation log.

### Uninstall Mode:
1. Remove NodeJS binaries and directory.
2. Remove symbolic links.
3. Restore the .bash_profile to its original state.
4. Send a completion email with the uninstallation log.

## Features
- Automates the installation and uninstallation of NodeJS version 18.
- Dynamically sets installation log file paths.
- Handles prerequisite package installations using YUM.
- Updates user .bash_profile for environment setup.
- Verifies installation by checking version of Node and npm.
- Cleans up installation and restores system state on uninstallation.
- Emails a log file upon completion of actions.

## Prerequisites

- NodeJS tarball (NodeJS18.tar.xz) and license properties file must be placed in the same directory as the script.
- YUM package manager needed. Necessary development packages like `openssl-devel`, `bzip2-devel`, `libicu-devel`, `gcc-c++`, and `make` need to be installed.

## Variables

- `EMAIL_RECIPIENT`: Email address to receive log notifications.
- `HOSTNAME`: Hostname of the system where the script is executed.
- `INSTALLDIR`: Directory for NodeJS installation.
- `NPM_VERSION`, `VERSION18`: Specific versions of npm and NodeJS to be installed.
- `DISTRO18`: Target distribution identifier.
- `NODEJSFILE`: Constructed filename for the NodeJS installation file.
- `FILEPATH`: Path to the NodeJS binary files.
- `YUM_PACKAGES`: List of packages to be installed via YUM.
- `LOGDIR`: Directory for storing log files.
- `DATE`: Current date and time, used in logs and filenames.

## Functions

- `log`: Appends a timestamped message to the installation log file.
- `send_email`: Sends an email with the log file as its content.
- `install_YUM_packages`: Installs required YUM packages and logs the installation status.
- `extract_nodejs`: Extracts the NodeJS installation tarball.
- `install`: Orchestrates the complete installation and verification process.
- `uninstall`: Handles the uninstallation process and system cleanup.

# Execution Logic:
## Command-Line Arguments Check:
### Explanations
1. **Header:**
   - `## Check for command-line arguments for MODE (VERY IMPORTANT)`: This line creates a header in your markdown document, emphasizing the importance of this script section.
2. **Script Purpose:**
   - `This script checks for the 'MODE' argument passed on the command line and overrides an internal 'MODE' variable if provided.`: This line explains what the script does in plain language.
3. **Code Block:**
   - `sh`: This indicates a code block in your markdown document, formatted for shell scripts (commonly used to write command-line tools).
```bash
   for ARG in "$@"
   do
     case $ARG in
       install|uninstall)
         echo "Arg: $ARG"
         MODE=$ARG  # Override MODE if it's "install" or "uninstall"
         echo "MODE=${MODE}"
       ;;
       *)
         # Handle other arguments or ignore
       ;;
     esac
   done
```
# Main Execution Logic
### Explanations
- **`case ${MODE} in`**: This statement evaluates the `MODE` variable.
    - **`install`**: Executes the `install` function if `MODE` is set to 'install'. This function should encompass all tasks necessary to install the software, such as setting up directories, installing dependencies, and configuring settings.
    - **`uninstall`**: Executes the `uninstall` function if `MODE` is set to 'uninstall'. This function is responsible for removing installed components, cleaning up directories, and restoring settings to their original state.
    - **`*` (default case)**: Handles any input that does not match the specified options ('install' or 'uninstall'). It informs the user of the correct usage of the script and exits with a status of 1 to indicate an error, preventing any unintended actions.

```bash
# This case statement directs the flow based on the value of MODE
case ${MODE} in
    install)
        # If MODE is 'install', calls the install function to proceed with installation
        install
        ;;
    uninstall)
        # If MODE is 'uninstall', calls the uninstall function to handle uninstallation
        uninstall
        ;;
    *)
        # If an invalid mode is passed, it notifies the user of proper usage and exits
        echo "Invalid mode. Usage: MODE={install|uninstall} $0 or $0 {install|uninstall}"
        exit 1
        ;;
esac
```
## Check Variables
This script section outputs the values of key variables, useful for debugging and ensuring correct setup:
- `echo "${NODEJSFILE}"`: Displays the filename for the NodeJS installation.
- `echo "${FILEPATH}"`: Shows the path where NodeJS binaries are stored.
- `echo "${NODE_VERSION}"`: Prints the currently set NodeJS version.
- `echo "DATE=${DATE}"` and `printf "DATE=%s\n" ${DATE}`: Both commands output the current date and time, useful for logging and timestamping operations in the script.
- *These commands help verify that all necessary variables are properly initialized before the script performs more complex tasks.
## Additional Notes
- The script assumes mailx is configured for sending emails.
- Proper error handling is in place to exit the installation or uninstallation process upon encountering any significant failure, ensuring robustness.
- System modifications such as updates to the .bash_profile and creation of symbolic links are pivotal for the correct functioning of NodeJS after installation.
- It is critical that the correct file permissions and access rights are configured for the script to execute successfully.
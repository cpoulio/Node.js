# NodeJS.sh ReadMe!
## Nexus Tag:
- Node.JS-v18.20.3-linux-x64
- Node.JS-v20.18.0-linux-x64

## How to Install:

- Place the node-<*VERSION*>-linux-x64.tar.xz and the license file in the script's directory.

- Run the script with the *Install* with the NodeJS.sh script:
    `./NodeJS.sh install`

- Run the script with setup.sh, install is default and does not need an argument:
    `./setup.sh`

## How to Uninstall:
- Run the script with the *Uninstall* with the NodeJS.sh script:
    `./NodeJS.sh uninstall`

- Run the script with setup.sh *Uninstall*:
    `MODE=uninstall ./setup.sh`

## How to Update: This will run the  *Ininstall* and then *Uninstall* functions

- Run the script with the update with the NodeJS.sh script:
    `./NodeJS.sh update`

- Run the script with setup.sh update:
    `MODE=update ./setup.sh`

### Install Mode:
1. Install required YUM packages.
2. Extract NodeJS from the tarball.
3. Establish symbolic links for NodeJS binaries.
4. Update the .bash_profile to set the environment path.
5. Verify the NodeJS and npm installations.
6. Send a completion email with the installation log.

### Uninstall Mode:
1. Remove NodeJS binaries and directory.
2. Remove symbolic links.
3. Restore the .bash_profile to its original state.
4. Send a completion email with the uninstallation log.

## Features
- Automates the installation and uninstallation of NodeJS.
- Dynamically sets installation log file paths.
- Handles prerequisite package installations using YUM.
- Updates user .bash_profile for environment setup.
- Verifies installation by checking version of Node and npm.
- Cleans up installation and restores system state on uninstallation.
- Emails a log file upon completion of actions.

## Prerequisites

- YUM package manager needed. Necessary development packages like `openssl-devel`, `bzip2-devel`, `libicu-devel`, `gcc-c++`, and `make` need to be installed.
- Mailx is recommended but not required. This will alow you to recieve your log by email.

## Variables
- `EMAIL_RECIPIENT`: Email address to receive log notifications.
- `HOSTNAME`: Hostname of the system where the script is executed.
- `INSTALLDIR`: Directory for NodeJS installation.
- `NPM_VERSION`: Specific version of npm to be installed.
- `VERSION`: Specifies the version of NodeJS to be installed.
- `SOFTWARENAME`: Name of the software being installed, in this case, NodeJS.
- `NODE_VERSION`: NodeJS version with the `v` prefix, used in constructing the filename and directory paths.
- `LINUX_DISTRO`: Specifies the target Linux distribution architecture, typically set to `linux-x64`.
- `NODEJSFILE`: Constructed filename for the NodeJS installation file.
- `FILEPATH`: Path to the NodeJS binary files.
- `YUM_PACKAGES`: List of packages to be installed via YUM.
- `LOGDIR`: Directory for storing log files.
- `DATE`: Current date and time, used in logs and filenames.

## Check Variables
- `echo "Deployment Directory=${deploy_dir}"`: Displays the deployment directory being used; defaults to `.` if not explicitly set.
- `echo "${NODEJSFILE}"`: Shows the constructed filename for the NodeJS installation file.
- `echo "${FILEPATH}"`: Prints the path where NodeJS binary files are located.
- `echo "${NODE_VERSION}"`: Outputs the NodeJS version with the `v` prefix for clarity.
- `echo "DATE=${DATE}"`: Displays the current date and time, which is useful for log timestamps.
- `printf "DATE=%s\n" ${DATE}`: Another way to print the date, formatted in a specific way for readability in logs.
- `echo "${EMAIL}"`: Outputs the email address(es) used for notifications, verifying that they are correctly set.

*These commands help verify that all necessary variables are properly initialized before the script performs more complex tasks.

### Function Explanations

- `log()`: Logs a message with a timestamp to the specified log file, allowing tracking of script actions.
- `send_email()`: Sends an email notification with the contents of the log file, providing a summary of the script's actions.
- `install_YUM_packages()`: Installs necessary packages using YUM, ensuring prerequisites are in place before proceeding.
- `extract_nodejs()`: Checks for the presence of the NodeJS tar file and extracts it to the installation directory.
- `update_bash_profile()`: Updates the user's `.bash_profile` to include the NodeJS binary path and reloads the profile to apply changes.
- `temp_profile()`: Temporarily adds the NodeJS binary path to the current session's `PATH`.
- `backup_and_remove_old_paths()`: Backs up profile files and removes outdated NodeJS paths from them to prevent conflicts with the new installation.
- `install()`: Combines installation steps, including package installation, NodeJS extraction, path updates, symbolic link creation, and version verification. Sends a summary email upon completion.
- `uninstall()`: Removes NodeJS files, symbolic links, and profile entries to cleanly uninstall NodeJS from the system. Sends an email notification after uninstallation.
- `update()`: Uninstalls any existing NodeJS version and reinstalls the latest version, combining the `uninstall` and `install` functions for a complete update. An email summary is sent upon completion.

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

## Additional Notes
- The script assumes mailx is configured for sending emails.
- Proper error handling is in place to exit the installation or uninstallation process upon encountering any significant failure, ensuring robustness.
- System modifications such as updates to the .bash_profile and creation of symbolic links are pivotal for the correct functioning of NodeJS after installation.
- It is critical that the correct file permissions and access rights are configured for the script to execute successfully.

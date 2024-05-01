# NodeJS 18 Installation and Uninstallation Script

This Bash script automates the installation and verification of NodeJS 18 on a Linux system. It handles the setup of the necessary environment, creates symbolic links for node, npm, and npx, and performs clean-up during uninstallation.

## Features

- Automatically install and verify NodeJS 18 with npm.
- Set up symbolic links for node, npm, and npx.
- Clean up installation files during uninstallation.
- Send email notifications upon completion of install/uninstall actions.
- Update user's `.bash_profile` to include the NodeJS path.

## Prerequisites

- The script assumes a Linux environment with `yum` package manager.
- Ensure that `mailx` is installed for the email notification feature.

## Installation

1. Download the `NodeJS18.tar.xz` file and the corresponding license properties file.
2. Place both files in the same directory as this script.
3. Run the script with the following command to install NodeJS 18:

   ```bash
   ./NodeJS.sh install

## Uninstallation
To uninstall NodeJS 18, run the script with the following command: ./NodeJS.sh uninstall

# Configuration
## Deployment Directory
Deployment Directory=deploy_dir This is the default Ansible directory.

# Configuration Variables
EMAIL_RECIPIENT: The email address to which notifications will be sent.
INSTALLDIR: Directory where NodeJS will be installed.
LOGDIR: Directory where logs will be stored.
NODE_VERSION: The specific version of NodeJS to be installed.
YUM_PACKAGES: A list of required YUM packages that the script will install.
# Functions
## install()
Handles the installation and verification of NodeJS.
Sets up necessary environment variables and paths.
Creates symbolic links for node, npm, and npx.
Updates the .bash_profile to include the NodeJS path.
Sends an email upon successful installation.
## uninstall()
Removes installed NodeJS and associated files.
Reverts changes made to .bash_profile.
Sends an email upon successful uninstallation.
# Execution Logic
The script checks the mode (install or uninstall) based on command-line arguments and executes the corresponding function. It exits with an error if an invalid mode is specified.

## Overide MODE logic for local testing .sh script without setup.sh
## Check for command-line arguments for MODE
for ARG in "$@"
do
    case $ARG in
        install|uninstall)
            echo "Arg: $ARG"
            MODE=$ARG # Important Override MODE if provided as a command-line argument
            echo "MODE=${MODE}" #Important to check what Option is passed for MODE
            printf "MODE=%s\n" ${MODE} #Important to check what Option is passed for MODE
            ;;
        *)
            # Handle other arguments or ignore
            ;;
    esac
done

## Main Logic
case ${MODE} in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Invalid mode. Usage: MODE={install|uninstall} $0 or $0 {install|uninstall}"
        exit 1
        ;;
esac


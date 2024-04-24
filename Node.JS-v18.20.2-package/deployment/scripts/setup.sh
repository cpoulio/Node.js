#!/bin/bash

# ${deploy_dir} is set by Ansible and represents the directory where the script is executed.
# No need to set a default for ${deploy_dir} since it's provided by Ansible.
# You have to have something (MODE for example ) to pass into the script so you can use the Options {install| uninstall| update}. Install is the default.
#

# **** IMPORTANT*****  MODE has to stand for NULL ("") so the if an Option is selecet then the it will excicute the default is install. ****
if [[ ${MODE} = "" ]]; then
   MODE="install"
fi
##################################################################################################################

echo "MODE=${MODE}" # Testing to see if install or uninstall comes across
echo "Deployment Directory=${deploy_dir}"  # Confirming the directory set by Ansible


# Assuming AEM_SCRIPT.sh is in the same directory as managed by Ansible (${deploy_dir})
SCRIPT="${deploy_dir}/NodeJS.sh"
#SCRIPT="./NodeJS.sh"

# Execute the firefox.sh script with the chosen mode
case ${MODE} in
    install)
        echo "Switching to install mode..."
        $SCRIPT install
        ;;
    uninstall)
        echo "Switching to uninstall mode..."
        $SCRIPT uninstall
        ;;
    update)
        echo "Switching to update mode..."
        $SCRIPT verify
        ;;
    *)
        echo "Invalid mode. Usage: $0 {install|uninstall|verify}"
        exit 1
        ;;
esac

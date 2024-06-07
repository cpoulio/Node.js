#!/bin/sh
#
#  NO INPUT is required in Ansible Deployment unless;
#       -  You need to override the MODE (default is install [other vals: reinstall, uninstall, forceuninstall])
#       -  You need to provide a INSTALLDIR (default is /usr/local)
#

# Check if INSTALLDIR parameter is passed
if [[ "x$INSTALLDIR" = "x" ]]; then
   INSTALLDIR="/usr/local"
fi

# Check if EMAIL parameter is passed
if [[ "E$EMAIL" = "E" ]]; then
   EMAIL="christopher.g.pouliot@irs.gov"
else
   EMAIL="christopher.g.pouliot@irs.gov,${EMAIL}"
fi

echo "EMAIL=$EMAIL"
echo "INSTALLDIR=$INSTALLDIR"
echo "MODE=$MODE"
echo "Deployment Directory=${deploy_dir}"


# Check if we need to install or uninstall Node.JS v18.17.1
if [[ "$MODE" = "uninstall" ]]; then
   echo "The customer requested to uninstall Node.JS v18.17.1. Uninstalling Node.JS v18.17.1 ..."
   ${deploy_dir}/run_remove_nodejs_v18171.sh ${INSTALLDIR} ${EMAIL}
else
   # Default is "install"
   echo "The customer requested to install Node.JS v18.17.1. Installing Node.JS v18.17.1 ..."
   ${deploy_dir}/run_install_nodejs_v18171.sh ${INSTALLDIR} ${EMAIL} ${deploy_dir}
   ${deploy_dir}/run_verify_nodejs_v18171.sh ${INSTALLDIR} ${EMAIL} ${deploy_dir}
fi

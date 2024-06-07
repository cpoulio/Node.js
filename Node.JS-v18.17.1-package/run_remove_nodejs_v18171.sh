#!/bin/bash

##############################################################################
# Set variables
##############################################################################

VERSION=v18.20.2
DISTRO=linux-x64
logdir=/tmp
logfile=NodeJS_$VERSION_remove.log
INSTALLDIR=$1
EMAIL=$2

##########################################################################
# Remove Node.js
##########################################################################

printf "\n" > $logdir/$logfile
DATE=`date +%m%d%Y`

#Remove NodeJS
if [ -d $INSTALLDIR/lib/nodejs18 ]; then
   rm -rf $INSTALLDIR/lib/nodejs18
   rm -f /usr/local/bin/npx
   rm -f /usr/local/bin/npm
   rm -f /usr/local/bin/node
   cp -p ~/.bash_profile ~/.bash_profile.bak.$DATE
   sed -i 's/#PATH=/PATH=/' ~/.bash_profile
   sed -i '/VERSION18=v18.20.2/d' ~/.bash_profile
   sed -i '/DISTRO18=linux-x64/d' ~/.bash_profile
   sed -i '/export PATH=$INSTALLDIR\/lib\/nodejs18\/node-$VERSION18-$DISTRO18\/bin:$PATH/d' ~/.bash_profile
   sed -i '/export PATH=$PATH:$HOME\/bin/d' ~/.bash_profile
   printf "NodeJS removed cleanly." |sed G >> $logdir/$logfile
else
   printf "NodeJS does not exist under $INSTALLDIR/lib/nodejs18" |sed G >> $logdir/$logfile
fi

################################################################################
# email log file
################################################################################

chmod 775 $logdir/$logfile
cat $logdir/$logfile | mailx -s "`uname -n`_$logfile" $EMAIL

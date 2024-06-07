#!/bin/bash

##############################################################################
# Set variables
##############################################################################

VERSION=v18.20.2
DISTRO=linux-x64
logdir=/tmp
logfile=NodeJS_$VERSION_verify.log
INSTALLDIR=$1
EMAIL=$2

##############################################################################
# Verify NodeJS Insallation
##############################################################################

printf "\n" > $logdir/$logfile

printf "Verifying the install of NodeJS $VERSION" |sed G >> $logdir/$logfile

export PATH="$PATH:/usr/local/bin:/usr/local"

#NODECHECK=`/usr/local/bin/node -v`
NODECHECK=`$INSTALLDIR/lib/nodejs18/node-$VERSION-$DISTRO/bin/node -v`

if [[ $NODECHECK = "v18.20.2" ]]; then
   printf "NodeJS $VERSION $INSTALLDIR/lib/nodejs18/node-$VERSION-$DISTRO has been successfully installed" |sed G >> $logdir/$logfile
else
   printf "The installation of NodeJS failed" |sed G >> $logdir/$logfile
   chmod 775 $logdir/$logfile
   cat $logdir/$logfile | mailx -s "`uname -n`_$logfile" $EMAIL
   exit 2
fi

#NPMCHECK=`/usr/local/bin/npm -v`
NPMCHECK=`$INSTALLDIR/lib/nodejs18/node-$VERSION-$DISTRO/bin/npm -v`

if [[ $NPMCHECK = "9.6.7" ]]; then
   printf "The update of npm to version $NPMCHECK $INSTALLDIR/lib/nodejs18/node-$VERSION-$DISTRO was successful" |sed G >> $logdir/$logfile
else
   printf "The update of npm failed" |sed G >> $logdir/$logfile
   chmod 775 $logdir/$logfile
   cat $logdir/$logfile | mailx -s "`uname -n`_$logfile" $EMAIL
   exit 2
fi

printf "\nOutput of NPM Version ...." >> $logdir/$logfile
$INSTALLDIR/lib/nodejs18/node-$VERSION-$DISTRO/bin/npm version >> $logdir/$logfile
#su - buildsrdstestsvc -c "npm version" >> $logdir/$logfile

printf "\n" >> $logdir/$logfile
printf "\n***************Verification of NodeJS $VERSION under $INSTALLDIR/lib/nodejs/node-$VERSION-$DISTRO has completed*********\n" >> $logdir/$logfile
printf "\n" >> $logdir/$logfile

################################################################################
# email log file
################################################################################

chmod 775 $logdir/$logfile
cat $logdir/$logfile | mailx -s "`uname -n`_$logfile" $EMAIL

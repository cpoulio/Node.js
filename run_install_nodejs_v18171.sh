#!/bin/bash

##############################################################################
# Set variables
##############################################################################

VERSION18=v18.17.1
DISTRO18=linux-x64
logdir=/tmp
logfile=NodeJS_$VERSION18_install.log
INSTALLDIR=$1
EMAIL=$2
DISTDIR=$3

##########################################################################
# Remove versions of Node.JS other than v18.17.1 
##########################################################################

printf "\n" > $logdir/$logfile

PROVERSION=`cat ~/.bash_profile |grep VERSION18= |head -1 |awk -F= '{print $2}'`
if [ 0$PROVERSION == 0 ]; then
   echo "$VERSION18"
   sed -i -e 's|^PATH=\$PATH:\$HOME/bin|#PATH=\$PATH:\$HOME/bin|' ~/.bash_profile
   echo "" >> ~/.bash_profile
   echo "VERSION18=$VERSION18" >> ~/.bash_profile
   echo "DISTRO18=linux-x64" >> ~/.bash_profile
   echo "export PATH=\$INSTALLDIR/lib/nodejs18/node-\$VERSION18-\$DISTRO18/bin:\$PATH" >> ~/.bash_profile
   echo "export PATH=\$PATH:\$HOME/bin" >> ~/.bash_profile
   echo ".bash_profile was updated!"
   #echo "NodeJS $PROVERSION was already installed!"
elif [[ x$PROVERSION < "x$VERSION18" ]]; then
   sed -i -e 's/$PROVERSION/$VERSION18/g' ~/.bash_profile
   echo ".bash_profile was updated!"
else
   echo ".bash_profile update is not required!"
fi
#Refresh .bash_prof
. ~/.bash_profile > /dev/null

printf "Installing NodeJS $VERSION18" |sed G >> $logdir/$logfile

cd $INSTALLDIR 
mkdir -p $INSTALLDIR/lib/nodejs18
tar -xvf $DISTDIR/node-$VERSION18-$DISTRO18.tar -C $INSTALLDIR/lib/nodejs18 |sed G >> $logdir/$logfile
chmod 755 -R $INSTALLDIR/lib/nodejs18

if [ $? = "0" ]; then
   printf "The command to install NodeJS $VERSION18 on $INSTALLDIR/lib/nodejs18 ran successfully" |sed G >> $logdir/$logfile
   printf "Fixing npm logging issue" |sed G >> $logdir/$logfile
    cd $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/lib/node_modules/npm/node_modules/npmlog/lib
    cp log.js log.js.org
    sed -i -e 's|log.progressEnabled|//log.progressEnabled|' log.js
    if grep "//log.progressEnabled" log.js > /dev/null; then
       printf "npm logging fix applied successfully" |sed G >> $logdir/$logfile
    else
       printf "npm logging fix failed" |sed G >> $logdir/$logfile
    fi
else
   printf "The command to install NodeJS $VERSION18 on $INSTALLDIR/lib/nodejs18 may not have run successfully and the install may have failed" |sed G >> $logdir/$logfile
fi

# Establish Symbolic Links
ln -s $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/node /usr/local/bin/node |sed G >> $logdir/$logfile
ls -l /usr/local/bin/node |sed G >> $logdir/$logfile
ln -s $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/npm /usr/local/bin//npm |sed G >> $logdir/$logfile
ls -l /usr/local/bin/npm |sed G >> $logdir/$logfile
ln -s $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/npx /usr/local/bin/npx |sed G >> $logdir/$logfile
ls -l /usr/local/bin/npx |sed G >> $logdir/$logfile

printf "Updating ownership in $INSTALLDIR/lib/nodejs18" |sed G >> $logdir/$logfile
find $INSTALLDIR/lib/nodejs18 -user 500 -exec chown root:root {} \; >> $logdir/$logfile

if [ $? = "0" ]; then
   printf "Updating ownership of $INSTALLDIR/lib/nodejs18 was successful" |sed G >> $logdir/$logfile
else
   printf "Updating ownership of $INSTALLDIR/lib/nodejs18 failed" |sed G >> $logdir/$logfile
fi

printf "Updating link ownership on $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/npm" |sed G >> $logdir/$logfile
chown -h root:root $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/npm >> $logdir/$logfile

if [ $? = "0" ]; then
   printf "Updating link ownership of $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/npm was successful" |sed G >> $logdir/$logfile
else
   printf "Updating link ownership of $INSTALLDIR/lib/nodejs18/node-$VERSION18-$DISTRO18/bin/npm failed" |sed G >> $logdir/$logfile
fi


printf "\n" >> $logdir/$logfile
printf "\n***************Install of NodeJS $VERSION18 under $INSTALLDIR/lib/nodejs18 has completed*********\n" >> $logdir/$logfile
printf "\n" >> $logdir/$logfile

################################################################################
# email log file
################################################################################

chmod 775 $logdir/$logfile
cat $logdir/$logfile | mailx -s "`uname -n`_$logfile" $EMAIL

#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit 2
fi

IS_CHROOT=0 # changed to 1 if and only if in chroot mode
USERNAME=""
DIR_DEVELOP=""

# The remastering process uses chroot mode.
# Check to see if this script is operating in chroot mode.
# /srv directory only exists in chroot mode
if [ -d "/srv" ]; then
	IS_CHROOT=1 # in chroot mode
	DIR_DEVELOP=/usr/local/bin/develop 
else
	USERNAME=$(logname) # not in chroot mode
	DIR_DEVELOP=/home/$USERNAME/develop 
fi
# This is the script for transforming antiX Linux into Regular Swift Linux.


sh $DIR_DEVELOP/1-build/shared-diet.sh
sh $DIR_DEVELOP/regular/main.sh
sh $DIR_DEVELOP/remove_languages/main.sh

# Remove stored *.deb files, must be executed after all packages are installed
sh $DIR_DEVELOP/1-build/remove_deb.sh 

exit 0

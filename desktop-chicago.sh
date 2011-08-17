#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit
fi

# This is the script for transforming antiX Linux into Swift Linux on the desktop.

USERNAME=$(logname)
DIR_DEVELOP=/home/$USERNAME/develop

su -c "sh $DIR_DEVELOP/1-build/preinstall-chicago.sh" $USERNAME

rm -r $DIR_DEVELOP/temp
su -c "mkdir $DIR_DEVELOP/temp" $USERNAME
sh $DIR_DEVELOP/1-build/shared-chicago.sh | tee $DIR_DEVELOP/temp/screenoutput.txt

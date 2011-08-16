#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ $( id -u ) -eq 0 ]; then
	echo "You must NOT be root to run this script."
	exit 2
fi

USERNAME=$(logname)
DIR_DEVELOP=/home/$USERNAME/develop

# This is the script that prepares for the transformation from antiX Linux
# to Regular Swift Linux

sh $DIR_DEVELOP/1-build/get-reps-regular.sh

exit 0

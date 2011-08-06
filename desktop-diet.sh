#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit
fi

# This is the script for transforming antiX Linux into Diet Swift Linux.

USERNAME=$(logname)
DIR_DEVELOP=/home/$USERNAME/develop

su -c "sh $DIR_DEVELOP/1-build/get_reps_diet.sh" $USERNAME

rm -r $DIR_DEVELOP/temp
su -c "mkdir $DIR_DEVELOP/temp" $USERNAME
sh $DIR_DEVELOP/1-build/shared-diet.sh | $DIR_DEVELOP/temp/screenoutput.txt

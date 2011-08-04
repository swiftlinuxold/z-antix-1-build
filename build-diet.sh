#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit
fi

# This is the script for creating the Diet Swift Linux ISO.

USERNAME=$(logname)
DIR_DEVELOP=/home/$USERNAME/develop

echo "Go to the VirtualBox menu, select Devices -> CD/DVD Devices,"
echo "and select the antiX Linux ISO."
echo "This mounts the virtual antiX Linux CD."
		
echo "Press Enter when you are finished." 
read CD

su -c "sh $DIR_DEVELOP/1-build/get_reps_diet.sh" $USERNAME

bash $DIR_DEVELOP/1-build/remaster-diet.sh
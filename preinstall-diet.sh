#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ $( id -u ) -eq 0 ]; then
	echo "You must NOT be root to run this script."
	exit 2
fi

USERNAME=$(logname)

# This is the script that prepares for the transformation from antiX Linux
# to Swift Linux

sh /home/$USERNAME/develop/1-build/get-reps-diet.sh
sh /home/$USERNAME/develop/installer/compile.sh

exit 0

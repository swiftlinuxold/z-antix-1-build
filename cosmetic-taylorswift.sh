#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit 2
fi

USERNAME=$(logname) # not in chroot mode
DIR_DEVELOP=/home/$USERNAME/develop 

# This is the script for creating the cosmetic appearance of Swift Linux.
# This script is used for testing the details of special editions.
# (These details are Conky, IceWM, ROX, SLiM, sound, and the wallpaper.)

su -c "sh $DIR_DEVELOP/1-build/preinstall-regular.sh" $USERNAME

sh $DIR_DEVELOP/conky/main.sh
sh $DIR_DEVELOP/icewm/main.sh
sh $DIR_DEVELOP/installer/main.sh
sh $DIR_DEVELOP/rox/main.sh
sh $DIR_DEVELOP/slim/main.sh
sh $DIR_DEVELOP/wallpaper-standard/main.sh

python $DIR_DEVELOP/regular/conky.py
python $DIR_DEVELOP/regular/mime.py
python $DIR_DEVELOP/regular/rox.py

python $DIR_DEVELOP/regular/conky.py
python $DIR_DEVELOP/regular/mime.py
python $DIR_DEVELOP/regular/rox.py

exit 0

#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ $( id -u ) -eq 0 ]; then
	echo "You must NOT be root to run this script."
	exit
fi

USERNAME=$(logname)

# This is the script for obtaining all of the repositories needed to generate Diet Swift Linux.

get_rep ()
	{
	if [ -d "/home/$USERNAME/develop/$1" ]; then
		echo "Repository $1 already present."
	else
		cd /home/$USERNAME/develop
		git clone git@github.com:swiftlinux/$1.git
	fi
	return 0
	}


get_rep 0-intro
get_rep add_help
get_rep apt
get_rep conky
get_rep control_center
get_rep iceape
get_rep icewm
get_rep installer
get_rep menu-update
get_rep remove_languages
get_rep rox
get_rep security
get_rep slim
get_rep sylpheed
get_rep wallpaper-standard

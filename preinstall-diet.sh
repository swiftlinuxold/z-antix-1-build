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
# to Swift Linux

get_rep ()
	{
	if [ -d $DIR_DEVELOP/$1 ]; then
		echo "Repository $1 already present."
	else
		cd $DIR_DEVELOP
		git clone git@github.com:swiftlinux/$1.git
	fi
	return 0
	}

echo "PREPARING TO DOWNLOAD REPOSITORIES"
echo
echo "Requesting and saving your password"
# From http://info.solomonson.com/content/setting-ssh-agent-ask-passphrase-only-once
# Start up ssh-agent to save your password.
# This allows you to download all repositories while entering your password just once.
tempfile=/tmp/ssh-agent.test
 
#Check for an existing ssh-agent
if [ -e $tempfile ]
then
    echo "Examining old ssh-agent"
    . $tempfile
fi
 
#See if the agent is still working
ssh-add -l > /dev/null
 
#If it's not working yet, just start a new one.
if [ $? != 0 ]
then
    echo "Old ssh-agent is dead..creating new agent."
 
    #Create a new ssh-agent if needed
    ssh-agent -s > $tempfile
    . $tempfile
 
    #Add the key
    ssh-add
fi    
 
#Show the user which keys are being used.
ssh-add -l

# ssh-agent is now implemented.  Now it's time to download all repositories.
echo "Downloading repositories"

# Get repositories for Diet Swift Linux
get_rep 0-intro
get_rep add_help
get_rep apt
get_rep conky
get_rep control_center
get_rep iceape
get_rep icewm
get_rep installer
get_rep menu-update
get_rep mime
get_rep new-iso
get_rep remove_languages
get_rep remove_packages
get_rep rox
get_rep security
get_rep slim
get_rep sylpheed
get_rep wallpaper-standard

rm -r /tmp/ssh* # Delete the saved password
echo "Finished downloading repositories and deleting your password."

sh $DIR_DEVELOP/installer/compile.sh

exit 0

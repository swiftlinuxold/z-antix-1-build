#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit
fi

echo "Removing *.deb files from /var/cache/apt/archives"
rm /var/cache/apt/archives/*.deb
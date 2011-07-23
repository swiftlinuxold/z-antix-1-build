#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ $( id -u ) -eq 0 ]; then
	echo "You must NOT be root to run this script."
	exit
fi

echo "Removing *.deb files from /var/cache/apt/archives"
rm /var/cache/apt/archives/*.deb
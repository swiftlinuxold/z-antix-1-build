#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit
fi

# This is the script for transforming antiX Linux into Diet Swift Linux.

sh ../apt/main.sh
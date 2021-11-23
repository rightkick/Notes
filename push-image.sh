#!/bin/bash
# This script will push a docker image that have been generated with docker save to a remote host with SSH. 
# Accept the image as first arg and the destination host as second. 

# Path
PATH="/bin:/sbin:/usr/bin:/usr/sbin"
PROGNAME=$(basename $0)

info_print()
{
    echo -e "\e[33m[\e[36m$1\e[33m]\e[0m"
}

info2_print()
{
    echo -e "\e[33m[\e[92m$1\e[33m]\e[0m"
}

error_print()
{
    echo -e "\e[33m[\e[31m$1\e[33m]\e[0m"
}

# Verify two arguments are given
if [ "$#" -ne 2 ]; then
	error_print "Usage: $PROGNAME <docker image> <destination host>"
	exit;
fi

# Docker image
DockerImage=$1

# Destination Host
DestHost=$2

# Color coding
echo -e "\e[33m[\e[36m"

# Push the image (you need root access to destination host and configured SSH client with SSH keys)
cat $DockerImage | pv -p -s $(du -sb $DockerImage) | ssh -C $DestHost 'docker load' || error_print "ERROR when pushing image $DockerImage to $DestHost"

# Reset color coding
echo -e "\e[33m[\e[36m$1\e[33m]\e[0m"

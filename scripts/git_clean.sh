#!/bin/bash
# A script to clean local git branches that are already merged into main
# Author: A. Kaouris
# Revision: 16 Sept 2025

warn_print "!!! WARNING !!!"
read -p "You are about to delete all your local branches that are missing from remote! Do you really want to proceed? Y/[N]: " confirmation
answer=${confirmation:-N}

if [ $answer = N ] || [ $answer = n ];then
    info_print "Ouff...that was near..."
    exit 0;
else
    git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do info_print "Deleting local branch $branch"; git branch -D $branch; done
fi

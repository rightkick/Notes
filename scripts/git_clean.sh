#!/bin/bash
# A script to clean local git branches that are already merged into main
# Author: A. Kaouris
# Revision: 16 Sept 2025

# Colors
BLUE="\033[0;34m"
ORANGE="\033[38;5;208m"
RED="\033[0;31m"
RESET="\033[0m"

# Functions
info_print() {
  echo -e "${BLUE}[INFO] $1${RESET}"
}

warn_print() {
  echo -e "${ORANGE}[WARN] $1${RESET}"
}

error_print() {
  echo -e "${RED}[ERROR] $1${RESET}"
}

warn_print "!!! WARNING !!!"
read -p "You are about to delete all your local branches that are missing from remote! Do you really want to proceed? Y/[N]: " confirmation
answer=${confirmation:-N}

if [ $answer = N ] || [ $answer = n ];then
    info_print "Ouff...that was near..."
    exit 0;
else
    git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do info_print "Deleting local branch $branch"; git branch -D $branch; done
fi

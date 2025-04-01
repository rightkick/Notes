#!/bin/bash
# A script to clean local git branches that are already merged into main
# Author: A. Kaouris
# Revision: 27 Feb 2025

# Get current git branch
git_branch_cur=$(git rev-parse --abbrev-ref HEAD)

# Get main branch
git_branch_main=$(git branch -l main master --format '%(refname:short)')

# Check if there are any local branches that are already merged
git_local_merged=$(git branch --merged "${git_branch_main}" | grep -v ${git_branch_cur} | grep -vE "${git_branch_main}|${git_branch_cur}")

if [ ! -z "${git_local_merged}" ];then

    echo "You are going to delete local git branches that are already merged with main"
    read -p "Are you sure you want to continue? (y/n): " choice
    case "$choice" in 
    y|Y ) echo "Proceeding...";;
    n|N ) echo "Aborted."; exit 1;;
    * ) echo "Invalid input. Please enter y or n."; exit 1;;
    esac

    # Clean local branches that have been merged with main
    for i in $(git branch --merged ${git_branch_main} | grep -v ${git_branch_cur} | grep -vE "${git_branch_main}|${git_branch_cur}");do 
        git branch -d $i;
    done
else
    echo "No local branches to clean"
fi
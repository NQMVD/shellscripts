#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to get remote platform
get_remote_platform() {
    local remote_url=$(git config --get remote.origin.url)
    if [[ $remote_url == *"github.com"* ]]; then
        echo "GitHub"
    elif [[ $remote_url == *"gitlab.com"* ]]; then
        echo "GitLab"
    elif [[ $remote_url == *"bitbucket.org"* ]]; then
        echo "Bitbucket"
    else
        echo "Unknown"
    fi
}

# Function to get git status
get_git_status() {
    git fetch > /dev/null
    local status=$(git status --porcelain)
    if [[ -z $status ]]; then
        echo "Clean"
    else
        echo "Dirty"
    fi
}

# Iterate through directories
for dir in */; do
    if [ -d "$dir" ]; then
        cd "$dir" || exit 1
        if [ -d .git ]; then
            # Get repo information
            repo_name=$(basename "$PWD")
            branch=$(git rev-parse --abbrev-ref HEAD)
            remote_platform=$(get_remote_platform)
            status=$(get_git_status)

            # Construct colored string
            output="${CYAN}$repo_name ${PURPLE}($remote_platform) ${YELLOW}[$branch] "
            if [ "$status" == "Clean" ]; then
                output+="${GREEN}✓${NC}"
            else
                output+="${RED}✗${NC}"
            fi

            echo -e "$output"
        fi
        cd ..
    fi
done

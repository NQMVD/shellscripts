#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Initialize counters
total_repos=0
owned_repos=0

# Get your GitHub username using gh CLI
github_username=$(gh api user --jq '.login')

# Function to get remote platform
get_remote_platform() {
    local remote_url=$(git config --get remote.origin.url)
    if [[ $remote_url == *"github.com"* ]]; then
        echo ""
    elif [[ $remote_url == *"gitlab.com"* ]]; then
        echo ""
    elif [[ $remote_url == *"bitbucket.org"* ]]; then
        echo ""
    else
        echo " ?"
    fi
}

# Function to get git status
get_git_status() {
    git fetch &> /dev/null
    local status=$(git status --porcelain)
    if [[ -z $status ]]; then
        echo "Clean"
    else
        echo "Dirty"
    fi
}

# Function to check if repo is owned by user
is_owned_by_me() {
    local remote_url=$(git config --get remote.origin.url)
    if [[ $remote_url == *"github.com/$github_username/"* ]]; then
        return 0  # Yes, owned by me
    else
        return 1  # Not owned by me
    fi
}

# Iterate through directories
for dir in */; do
    if [ -d "$dir" ]; then
        cd "$dir" || exit 1
        if [ -d .git ]; then
            ((total_repos++))

            # Get repo information
            repo_name=$(basename "$PWD")
            branch=$(git rev-parse --abbrev-ref HEAD)
            remote_platform=$(get_remote_platform)
            status=$(get_git_status)

            # Check ownership
            if is_owned_by_me; then
                ((owned_repos++))
                ownership_symbol="${YELLOW}★${NC} "  # Symbol if owned by me
            else
                ownership_symbol="  "  # Space if not owned by me
            fi

            # Construct colored string
            output="${ownership_symbol}${CYAN}$repo_name ${PURPLE}$remote_platform ${BLUE}[$branch] "
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

# Print repo counts or "No repos found" message
if [ "$total_repos" -eq 0 ]; then
    echo -e "${RED}No repositories found${NC}"
else
    echo -e "${BLUE}──────────────────────${NC}"
    echo -e "${CYAN}Total Repositories: ${total_repos}${NC}"
    echo -e "${BLUE}Owned by me: ${owned_repos}${NC}"
fi

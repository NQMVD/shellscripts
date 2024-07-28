#!/usr/bin/env bash

is not existing 'Cargo.toml' && gum log -l error 'No Cargo.toml file...' && exit 1

# Function to update the version in Cargo.toml
update_version() {
    local new_version=$1
    sed -i "s/^version = .*$/version = \"$new_version\"/" Cargo.toml
}

# Function to append to CHANGELOG.md
append_to_changelog() {
    local new_version=$1
    local commit_message=$2
    echo -e "## [$new_version] - $(date +%Y-%m-%d)\n\n$commit_message\n" >> CHANGELOG.md
}

# Read the current version from Cargo.toml
current_version=$(grep -E '^version = "' Cargo.toml | cut -d '"' -f2)
IFS='.' read -r -a version_parts <<< "$current_version"

major=${version_parts[0]}
minor=${version_parts[1]}
patch=${version_parts[2]}

# Prompt user to choose which component to increase
choice=$(gum choose --header "  [$current_version] - increase:" '1. MAJOR' '2. MINOR' '3. PATCH')
is equal "$?" 130 && gum log -l error 'User aborted...' && exit 1

# Prompt user for commit message
message=$(gum write --header "Changes:" --char-limit 0)
is equal "$?" 130 && gum log -l error 'User aborted...' && exit 1

# Update version based on user choice
case $choice in
    '1. MAJOR')
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    '2. MINOR')
        minor=$((minor + 1))
        patch=0
        ;;
    '3. PATCH')
        patch=$((patch + 1))
        ;;
esac

new_version="$major.$minor.$patch"

# Update Cargo.toml and CHANGELOG.md
update_version "$new_version"
append_to_changelog "$new_version" "$message"

echo "Version updated to $new_version"
echo "Changes appended to CHANGELOG.md"

#!/bin/bash

# Function to split the input string based on the provided delimiter
split_input() {
    local delimiter=$1
    local input=$(cat)

    # Split the input string and store chunks in an array
    IFS="$delimiter" read -ra chunks <<< "$input"

    # Print the chunks in a format suitable for storing in an array
    for chunk in "${chunks[@]}"; do
        echo -n "$chunk "
    done
    echo
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <delimiter>"
    exit 1
fi

# Call the split_input function with the provided delimiter
split_input "$1"

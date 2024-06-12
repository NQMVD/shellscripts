#!/bin/bash

# Function to convert hex to RGB using the HEX2RGB command
convert_hex_to_rgb() {
    local hex_color=$1
    rgb_color=$(gum style --background="$hex_color" --foreground="#000000" "$hex_color")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to convert $hex_color to RGB" >&2
        exit 1
    fi
    echo "$rgb_color"
}

# Read input from stdin
while IFS= read -r line; do
    # Use a regex to find all hex color codes in the line
    modified_line="$line"
    hex_colors=$(echo "$line" | grep -o -E '#[0-9a-fA-F]{6}')
    
    for hex_color in $hex_colors; do
        rgb_color=$(convert_hex_to_rgb "$hex_color")
        modified_line=$(echo "$modified_line" | sed "s/$hex_color/$rgb_color/g")
    done
    
    echo "$modified_line"
done

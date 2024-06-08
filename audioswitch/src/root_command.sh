# Function to list all available sound output devices
list_output_devices() {
    pactl list short sinks | awk '{print $2}'
}

# Function to set the default sound output device
set_output_device() {
    local device=$1
    pactl set-default-sink "$device"
}

# Function to display a menu and let the user choose an output device
choose_output_device() {
    local devices=($(list_output_devices))
    echo "Available sound output devices:"
    
    for i in "${!devices[@]}"; do
        echo "$i: ${devices[$i]}"
    done
    
    echo -n "Choose a device number: "
    read choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt "${#devices[@]}" ]; then
        set_output_device "${devices[$choice]}"
        echo "Switched to ${devices[$choice]}"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
}

# Main script execution
choose_output_device

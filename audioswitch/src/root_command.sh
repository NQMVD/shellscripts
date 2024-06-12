devices=($(pactl list short sinks | awk '{print $2}'))

choice=$(gum choose --header="Available sound output devices:" "${devices[@]}")

if is not empty "$choice"; then
    if pactl set-default-sink "$choice"; then 
        gum log -sl info 'Switched to' device "$choice"
    else
        gum log -sl error 'Failed to set' device "$choice"
    fi
else
    gum log -l error 'Aborted...'
    exit 1
fi

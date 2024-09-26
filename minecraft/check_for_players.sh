#!/bin/bash

# Path to discord.sh
DISCORD_SH="/usr/local/bin/discord"  # Change this to the actual path of discord.sh
WEBHOOK_URL="https://discordapp.com/api/webhooks/1283458571182276648/yU9hKJklJePdRZiNu268u442nvy1QkmHyVhfczHFqLkJQ14REyB5kIYmVsxEeIxo8zXo"  # Replace with your actual webhook URL

# Pueue job log command (adjust according to how your Pueue is set up)
if [ $# -eq 0 ]; then
    gum log -l error 'needs a pueue id:'
    pueue status -g MINECRAFT status=running
    exit 1
fi
PUEUE_ID="$1"
PUEUE_LOG_CMD="pueue log $PUEUE_ID"  # Replace with actual Pueue job ID or command

# Declare an associative array to keep track of player states
declare -A player_states

# Function to send notification
send_notification() {
    local player="$1"
    local action="$2"
    local message="$player $action the game"
    gum log -l info "$message"
    "$DISCORD_SH" --webhook-url="$WEBHOOK_URL" --text "$message"
}

# Function to check for server overload and notify
check_server_overload() {
    local line="$1"
    if [[ "$line" =~ Is\ the\ server\ overloaded\?\ Running\ ([0-9]+)ms\ behind ]]; then
        local ms="${BASH_REMATCH[1]}"
        send_notification "Warning: Server is overloaded! Running $ms ms behind."
    fi
}

# Function to update player state and notify if changed
update_player_state() {
    local player="$1"
    local new_state="$2"

    # If player state has changed, send a notification and update the state
    if [[ "${player_states[$player]}" != "$new_state" ]]; then
        player_states[$player]="$new_state"
        if [[ "$new_state" == "joined" ]]; then
            send_notification "$player" "joined"
        else
            send_notification "$player" "left"
        fi
    fi
}

# Gracefully handle Ctrl+C
trap "echo 'Terminating...'; exit 0" SIGINT

# Read full log and initialize player states
$PUEUE_LOG_CMD | grep -E "joined the game|left the game" | while read -r line; do
    if [[ "$line" =~ ^([a-zA-Z0-9_]+)\ joined\ the\ game ]]; then
        update_player_state "${BASH_REMATCH[1]}" "joined"
    elif [[ "$line" =~ ^([a-zA-Z0-9_]+)\ left\ the\ game ]]; then
        update_player_state "${BASH_REMATCH[1]}" "left"
    elif [[ "$line" =~ Is\ the\ server\ overloaded ]]; then
        check_server_overload "$line"
    fi
done

# Infinite loop to continuously check for new log entries every second
while true; do
    # Read only new logs from Pueue since last read
    last_log=$($PUEUE_LOG_CMD --lines=10)  # Adjust --lines based on how frequently logs update

    # Scan logs for join/leave messages
    while IFS= read -r line; do
        if [[ "$line" =~ ^([a-zA-Z0-9_]+)\ joined\ the\ game ]]; then
            update_player_state "${BASH_REMATCH[1]}" "joined"
        elif [[ "$line" =~ ^([a-zA-Z0-9_]+)\ left\ the\ game ]]; then
            update_player_state "${BASH_REMATCH[1]}" "left"
        elif [[ "$line" =~ Is\ the\ server\ overloaded ]]; then
            check_server_overload "$line"
        fi
    done <<< "$last_log"

    # Sleep for 1 second before checking again
    sleep 1
done

#!/usr/bin/env sh

log() {
  local LVL="$1"
  local MSG="$2"
  gum log -l "$LVL" "$MSG"
  discord --webhook-url='https://discordapp.com/api/webhooks/1283460725989183511/Y48zqWVz39aJPMwUpgP-Jwg3hzbu4F0erSPn5k1_WUgDiD390jRtLF2ijK5hBEjWvyu2' --text "> **$(echo $LVL | tr '[:lower:]' '[:upper:]'):** $MSG"
}

GROUPLIST=$(pueue status -g MINECRAFT status=running)
ISEMPTY=$(echo "$GROUPLIST" | rg -q -i -F 'empty')

if [ $ISEMPTY -eq 0 ]; then
  gum log -l error "another instance is still running:"
  pueue status -g MINECRAFT
  exit 1
fi

sudo mkfifo "$pwd/fifo-input-file"

ID=$(pueue add -p -g MINECRAFT -w "$(pwd)" 'tail -f fifo-input-file | java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.3.10/unix_args.txt')

sleep 30
log info "Minecraft Server [Monifactory] is now running!"

RESULT=$(pueue wait $ID)
echo "$RESULT" | rg -q 'succeeded'
SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
  log info "Minecraft Server [Monifactory] was shutdown."
else
  log error "Minecraft Server [Monifactory] encountered an error and/or failed!"
fi


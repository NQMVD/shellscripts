#!/usr/bin/env sh
# Forge requires a configured set of both JVM and program arguments.
# Add custom JVM arguments to the user_jvm_args.txt
# Add custom program arguments {such as nogui} to this file in the next line before the "$@" or
#  pass them to this script directly

log() {
  local LVL="$1"
  local MSG="$2"
  gum log -l "$LVL" "$MSG"
  discord --webhook-url='https://discordapp.com/api/webhooks/1283460725989183511/Y48zqWVz39aJPMwUpgP-Jwg3hzbu4F0erSPn5k1_WUgDiD390jRtLF2ijK5hBEjWvyu2' --text "> **$(echo $LVL | tr '[:lower:]' '[:upper:]'):** $MSG"
}

log info "Minecraft Server [Monifactory] is now running!"
tail -f /tmp/minecraft-input | java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.3.10/unix_args.txt
SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
  log info "Minecraft Server [Monifactory] was shutdown."
else
  log error "Minecraft Server [Monifactory] encountered and error and/or failed!"
fi


#!/usr/bin/env bash

# Define popular clipboard tools for each session type
case "$XDG_SESSION_TYPE" in
  x11)
    # X11 session type
    clipboard_tools=("xclip" "xsel" "klipper")
    ;;
  wayland)
    # Wayland session type
    clipboard_tools=("wl-clipboard" "wl-copy" "wl-paste")
    ;;
  *)
    # Unknown session type, default to X11 tools
    clipboard_tools=("xclip" "xsel" "klipper")
    ;;
esac

# Check if each clipboard tool is installed using which
for tool in "${clipboard_tools[@]}"; do
  if which "$tool" &> /dev/null; then
    echo "$tool"
    exit 0
  fi
done

# If no clipboard tool is detected, print an empty string
echo "NONE"

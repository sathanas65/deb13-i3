#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Log debugging info
LOG_FILE="/tmp/browser_debug.log"
exec >> "$LOG_FILE" 2>&1
echo "Script started at $(date)"

# Extract the tmux session name to decide which command to run
session_name=$(tmux display-message -p '#S')
#session_name="${1-}"
case "$session_name" in
    chatgpt)
        flatpak run com.brave.Browser   --profile-directory="GPT"   --new-window   --app="https://chatgpt.com"
        ;;
    
    *)
        notify-send "Session: $session_name" "Unknown session action: $session_name" -u critical
        echo "Unknown session action: $session_name."
        exit 1
        ;;
esac

exit 0

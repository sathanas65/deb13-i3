#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

LOG_FILE="/tmp/browser_debug.log"
exec >> "$LOG_FILE" 2>&1
echo "Script started at $(date)"

session_name=$(tmux display-message -p '#S')
echo "session_name=$session_name"

case "$session_name" in
    chatgpt)
        flatpak run com.brave.Browser \
            --profile-directory="Profile 5" \
            --new-window \
            --app="https://chatgpt.com"
        ;;
    cockpit)
        flatpak run com.brave.Browser \
            --profile-directory="Profile 5" \
            --new-window \
            --app="http://127.0.0.1:9090/"
        ;;
    *)
        notify-send "Session: $session_name" "Unknown session action: $session_name" -u critical
        echo "Unknown session action: $session_name"
        exit 1
        ;;
esac

exit 0

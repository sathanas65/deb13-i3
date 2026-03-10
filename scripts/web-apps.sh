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
            --profile-directory="Profile 6" \
            --new-window \
            --app="http://127.0.0.1:9090/"
        ;;
    voice)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://voice.google.com/"
        ;;
     nas)
        flatpak run com.brave.Browser \
            --profile-directory="Profile 6" \
            --new-window \
            --app="https://192.168.1.24:443"
        ;;
     proxmox)
        flatpak run com.brave.Browser \
            --profile-directory="Profile 6" \
            --new-window \
            --app="https://192.168.1.220:8006"
        ;;
     gmail)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://mail.google.com/"
        ;;
     amazon)
        flatpak run com.brave.Browser \
            --profile-directory="Profile 1" \
            --new-window \
            --app="https://www.amazon.com/"
        ;;
     ytmusic)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://music.youtube.com/"
        ;;
     gmaps)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://www.google.com/maps/"
        ;;
     gdrive)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://drive.google.com/drive/home"
        ;;
     gcalendar)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://calendar.google.com/calendar/"
        ;;
     gkeep)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://keep.google.com/"
        ;;
     gemini)
        flatpak run com.brave.Browser \
            --profile-directory="Default" \
            --new-window \
            --app="https://gemini.google.com/app"
        ;;
    *)
        notify-send "Session: $session_name" "Unknown session action: $session_name" -u critical
        echo "Unknown session action: $session_name"
        exit 1
        ;;
esac

exit 0

#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export I3SOCK="$(find /run/user/$(id -u)/i3 -maxdepth 1 -type s -name 'ipc-socket.*' 2>/dev/null | sort | tail -n1)"

LOG="$HOME/scripts/screenshot.log"

{
    echo "==== $(date) ===="
    echo "USER=$USER"
    echo "HOME=$HOME"
    echo "DISPLAY=$DISPLAY"
    echo "DBUS=$DBUS_SESSION_BUS_ADDRESS"
    echo "I3SOCK=$I3SOCK"
} >> "$LOG"

session_name=$(tmux display-message -p '#S' 2>>"$LOG")
echo "session_name=$session_name" >> "$LOG"

get_focused_output_geometry() {
    local output geometry

    output=$(i3-msg -t get_workspaces 2>>"$LOG" | jq -r '.[] | select(.focused==true).output')
    echo "output=$output" >> "$LOG"

    if [ -z "$output" ] || [ "$output" = "null" ]; then
        echo "ERROR: could not determine focused output" >> "$LOG"
        return 1
    fi

    geometry=$(xrandr | awk -v out="$output" '
        $1 == out {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
                    print $i
                    exit
                }
            }
        }
    ')
    echo "geometry=$geometry" >> "$LOG"

    if [ -z "$geometry" ]; then
        echo "ERROR: could not determine geometry for output $output" >> "$LOG"
        return 1
    fi

    printf '%s\n' "$geometry"
    return 0
}

timestamp() {
    date -u +'%Y%m%d-%H%M%SZ'
}

case "$session_name" in
    delaysave)
        geometry=$(get_focused_output_geometry) || {
            notify-send "Screenshot failed" "Could not determine focused monitor"
            exit 1
        }

        sleep 3

        file="$HOME/Pictures/screenshot-$(timestamp).png"
        echo "file=$file" >> "$LOG"

        maim --geometry="$geometry" --format=png "$file" 2>>"$LOG"
        rc=$?
        echo "maim_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ] && [ -f "$file" ]; then
            notify-send "Screen saved"
        else
            notify-send "Screenshot failed" "File was not created"
            exit 1
        fi
        ;;
    screensave)
        geometry=$(get_focused_output_geometry) || {
            notify-send "Screenshot failed" "Could not determine focused monitor"
            exit 1
        }

        file="$HOME/Pictures/screenshot-$(timestamp).png"
        echo "file=$file" >> "$LOG"

        maim --geometry="$geometry" --format=png "$file" 2>>"$LOG"
        rc=$?
        echo "maim_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ] && [ -f "$file" ]; then
            notify-send "Screen saved"
        else
            notify-send "Screenshot failed" "File was not created"
            exit 1
        fi
        ;;
    windowsave)
        winid=$(xdotool getactivewindow 2>>"$LOG")
        echo "winid=$winid" >> "$LOG"

        if [ -z "$winid" ]; then
            notify-send "Screenshot failed" "Could not determine active window"
            exit 1
        fi

        file="$HOME/Pictures/screenshot-$(timestamp).png"
        echo "file=$file" >> "$LOG"

        maim --format=png --window "$winid" "$file" 2>>"$LOG"
        rc=$?
        echo "maim_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ] && [ -f "$file" ]; then
            notify-send "Window saved"
        else
            notify-send "Screenshot failed" "File was not created"
            exit 1
        fi
        ;;
    selectsave)
        file="$HOME/Pictures/screenshot-$(timestamp).png"
        echo "file=$file" >> "$LOG"

        maim --format=png --select "$file" 2>>"$LOG"
        rc=$?
        echo "maim_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ] && [ -f "$file" ]; then
            notify-send "Selection saved"
        else
            notify-send "Screenshot failed" "File was not created"
            exit 1
        fi
        ;;
    screenclip)
        geometry=$(get_focused_output_geometry) || {
            notify-send "Screenshot failed" "Could not determine focused monitor"
            exit 1
        }

        maim --geometry="$geometry" --format=png 2>>"$LOG" | xclip -selection clipboard -t image/png
        rc=$?
        echo "clip_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ]; then
            notify-send "Screen clipped"
        else
            notify-send "Screenshot failed" "Clipboard copy failed"
            exit 1
        fi
        ;;
    windowclip)
        winid=$(xdotool getactivewindow 2>>"$LOG")
        echo "winid=$winid" >> "$LOG"

        if [ -z "$winid" ]; then
            notify-send "Screenshot failed" "Could not determine active window"
            exit 1
        fi

        maim --format=png --window "$winid" 2>>"$LOG" | xclip -selection clipboard -t image/png
        rc=$?
        echo "clip_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ]; then
            notify-send "Window clipped"
        else
            notify-send "Screenshot failed" "Clipboard copy failed"
            exit 1
        fi
        ;;
    selectclip)
        maim --format=png --select 2>>"$LOG" | xclip -selection clipboard -t image/png
        rc=$?
        echo "clip_exit=$rc" >> "$LOG"

        if [ $rc -eq 0 ]; then
            notify-send "Selection clipped"
        else
            notify-send "Screenshot failed" "Clipboard copy failed"
            exit 1
        fi
        ;;
    *)
        echo "Invalid session: $session_name" >> "$LOG"
        notify-send "Screenshot failed" "Invalid tmux session: $session_name"
        exit 1
        ;;
esac

exit 0

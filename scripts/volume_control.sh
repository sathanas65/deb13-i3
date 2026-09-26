#!/bin/bash

# Get action from first argument (up or down)
ACTION=$1
STEP=5
MAX_VOLUME=1.2   # wpctl uses a 0.0–1.5 fraction, so 120% = 1.2

SINK="@DEFAULT_AUDIO_SINK@"

# Adjust volume (wpctl's --limit caps the boost so it can't overshoot)
case "$ACTION" in
    up)   wpctl set-volume --limit "$MAX_VOLUME" "$SINK" "${STEP}%+" ;;
    down) wpctl set-volume --limit "$MAX_VOLUME" "$SINK" "${STEP}%-" ;;
esac

# Get the actual volume level as a whole-number percentage
VOLUME=$(wpctl get-volume "$SINK" | grep -oP '(?<=Volume: )[0-9.]+' | awk '{printf "%d", $1 * 100 + 0.5}')

# Send notification
dunstify -r 9993 "Volume" "${VOLUME}%"

#!/bin/bash

SINK="@DEFAULT_AUDIO_SINK@"

# Check mute status before toggling (wpctl reports it inline with volume)
if wpctl get-volume "$SINK" | grep -q "MUTED"; then
    wpctl set-mute "$SINK" toggle && dunstify "Mute Off"
else
    wpctl set-mute "$SINK" toggle && dunstify "Mute On"
fi

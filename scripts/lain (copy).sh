#!/bin/bash

# Directory containing the media files
MEDIA_DIR="/mnt/smb_share/Media-Videos/TV/Serial Experiments Lain (1520x1080 Blu-Ray FLAC)"

# Audio track index (0-based, so 1 means the second track)
AUDIO_TRACK=1

# Check if the directory exists
if [ ! -d "$MEDIA_DIR" ]; then
    echo "Directory $MEDIA_DIR not found!"
    exit 1
fi

# Initialize VLC command with audio track setting
VLC_CMD="vlc --audio-track $AUDIO_TRACK --fullscreen"

# Loop through each video file in the directory
for FILE in "$MEDIA_DIR"/*.mkv; do
    if [ -f "$FILE" ]; then
        VLC_CMD+=" \"$FILE\""
    fi
done

# Execute the VLC command with all files in the playlist
eval $VLC_CMD

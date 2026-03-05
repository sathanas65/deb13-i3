#!/bin/bash
# English audio + English subs, persistent crop

MEDIA_DIR="/mnt/smb_share/Media-Videos/TV/Serial Experiments Lain (1520x1080 Blu-Ray FLAC)"
AUDIO_TRACK=1        # English dub (0-based index)
SUB_LANG="eng"       # prefer English subtitles
TOP=112              # 5:4 → 16:9 crop
BOTTOM=113

[ -d "$MEDIA_DIR" ] || { echo "Missing dir: $MEDIA_DIR"; exit 1; }
shopt -s nullglob
files=("$MEDIA_DIR"/*.mkv)
[ ${#files[@]} -gt 0 ] || { echo "No mkv files"; exit 1; }

exec vlc --fullscreen \
  --audio-track "$AUDIO_TRACK" \
  --sub-language "$SUB_LANG" \
  --video-filter=croppadd \
  --croppadd-croptop="$TOP" \
  --croppadd-cropbottom="$BOTTOM" \
  "${files[@]}"

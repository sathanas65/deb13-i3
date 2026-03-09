#!/usr/bin/env bash
set -euo pipefail

OUT_LEFT="DisplayPort-1"
OUT_RIGHT="DVI-D-0"

WS_LEFT="Brave"
WS_RIGHT="Google"

command -v i3-msg >/dev/null
command -v brave-browser >/dev/null
command -v flatpak >/dev/null

# Stage workspaces on the intended outputs
i3-msg "focus output $OUT_LEFT; workspace \"$WS_LEFT\""
i3-msg "focus output $OUT_RIGHT; workspace \"$WS_RIGHT\""
i3-msg "focus output $OUT_LEFT; workspace \"$WS_LEFT\""

# If any Brave already running, exit
if pgrep -af 'brave-browser|com\.brave\.Browser' >/dev/null 2>&1; then
  exit 0
fi

# Launch APT Brave
i3-msg "focus output $OUT_LEFT; workspace \"$WS_LEFT\""
brave-browser \
  --class=BraveApt \
  --no-default-browser-check \
  --profile-directory="Default" \
  >/dev/null 2>&1 &

sleep 1

# Launch Flatpak Brave
i3-msg "focus output $OUT_RIGHT; workspace \"$WS_RIGHT\""
flatpak run com.brave.Browser \
  --class=BraveFlatpak \
  --profile-directory="Default" \
  >/dev/null 2>&1 &

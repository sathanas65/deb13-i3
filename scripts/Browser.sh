#!/usr/bin/env bash
set -euo pipefail

OUT_LEFT="DisplayPort-1"
OUT_RIGHT="DVI-D-0"

WS_LEFT="Brave"
WS_RIGHT="Google"

APT_BRAVE=(brave-browser --class=BraveApt --no-default-browser-check --profile-directory="Default")
#FP_BRAVE=(flatpak run com.brave.Browser --profile=Google --class=BraveFlatpak)
FP_BRAVE=(flatpak run com.brave.Browser --class=BraveFlatpak --profile-directory="Default")



command -v i3-msg >/dev/null
command -v jq >/dev/null

# Stage workspaces on the intended outputs
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\""
i3-msg "focus output $OUT_RIGHT; workspace \"$WS_RIGHT\""
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\""

# If ANY Brave already running, just show workspaces and exit
if pgrep -af 'brave|com\.brave\.Browser' >/dev/null 2>&1; then
  exit 0
fi

# Launch APT Brave on left ws, Flatpak Brave on right ws
i3-msg "focus output $OUT_LEFT;  workspace \"$WS_LEFT\";  exec --no-startup-id ${APT_BRAVE[*]}"
i3-msg "focus output $OUT_RIGHT; workspace \"$WS_RIGHT\"; exec --no-startup-id ${FP_BRAVE[*]}"

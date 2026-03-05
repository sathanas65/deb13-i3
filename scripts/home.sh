#!/usr/bin/env bash
set -euo pipefail

OUT_LEFT="DisplayPort-1"
OUT_RIGHT="DVI-D-0"

# Put workspaces on the desired outputs
i3-msg "workspace \"Dashboard\"; move workspace to output \"$OUT_LEFT\""
i3-msg "workspace \"Notes\";     move workspace to output \"$OUT_RIGHT\""

# End up focused on Dashboard on the left
i3-msg "focus output \"$OUT_LEFT\"; workspace \"Dashboard\""

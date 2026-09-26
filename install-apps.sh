#!/bin/bash
# =====================================================================
#  Add optional apps AFTER the main install
#
#  Run with:   bash install-apps.sh
#
#  Shows the same app menu as install.sh (nothing ticked), installs
#  what you pick, and does NOT reboot. Use it to add apps later or to
#  retry apps that failed during the main install.
# =====================================================================

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
USER="${USER:-$(id -un)}"

source "$REPO_DIR/app-picker.sh"
load_apps "$REPO_DIR/optional-apps.sh"

if ! have_tty; then
    echo "This needs a terminal to show the menu." >&2
    exit 1
fi

sudo -v
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null' EXIT

PICKER_INTRO="Tick the apps you want to add, then choose Install." \
PICKER_GO_LABEL=">>  Install ticked apps" \
choose_apps none
clear >/dev/tty 2>/dev/null || true
print_selection

if [ "$(count_selected)" -eq 0 ]; then
    echo "Nothing ticked - nothing to do."
    exit 0
fi

sudo apt-get update
install_selected_apps

if report_failures "$REPO_DIR/failed-apps.txt"; then
    echo
    echo "All done. Some apps (docker, kvm, nordvpn) need you to log out and back in first."
fi

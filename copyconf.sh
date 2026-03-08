#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# --- helpers ---
die() { echo "ERROR: $*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- locate repo safely ---
REPO="$HOME/deb13-i3"
[[ -d "$REPO" ]] || die "Repo not found at $REPO"
cd "$REPO"

mkdir -p \
"$HOME/.config" \
"$HOME/.local/share" \
"$HOME/scripts" \
"$HOME/.config/backgrounds" \
"$HOME/.config/i3" \
"$HOME/.config/i3blocks" \
"$HOME/.config/dunst" \
"$HOME/.config/rofi" \
"$HOME/.config/libreoffice" \
"$HOME/.local/share/konsole"

# --- copy configs (use -a to preserve perms/times; use source/. to avoid nesting) ---
#cp -a "config/libreoffice/." "$HOME/.config/"
#not working

# scripts
cp -a "scripts/." "$HOME/scripts/"

# backgrounds
cp -a "config/backgrounds/." "$HOME/.config/backgrounds/"

# i3 / bars / notifications / launchers
cp -a "config/i3/."       "$HOME/.config/i3/"
cp -a "config/i3blocks/." "$HOME/.config/i3blocks/"
cp -a "config/dunst/."    "$HOME/.config/dunst/"
cp -a "config/rofi/."     "$HOME/.config/rofi/"

# terminals
cp -a "config/terminator/." "$HOME/.config/terminator/" || true
cp -a "config/konsole/."    "$HOME/.local/share/konsole/" || true
cp -a "config/konsolerc"    "$HOME/.config/konsolerc" || true

# dashboard
cp -a "config/bpytop/."     "$HOME/.config/bpytop/" || true
cp -a "config/hyfetch.json" "$HOME/.config/hyfetch.json" || true

# browsers
#apt Brave
cp -a "config/BraveSoftware/."     "$HOME/.config/BraveSoftware/" || true
#flatpak Brave
mkdir -p "$HOME/.var/app/com.brave.Browser/config/"
cp -a "config/BraveSoftware/."     "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/" || true
#chromium
cp -a "config/chromium/."     "$HOME/.config/chromium/" || true
#mullvad
mullvad-browser --headless >/dev/null 2>&1 &
MB_PID=$!
# wait up to 20 seconds for the profile directory to appear
for i in {1..20}; do
    PROFILE_DIR=$(find "$PROFILE_ROOT" -maxdepth 1 -type d -name '*.default-release' | head -n1 || true)
    if [ -n "${PROFILE_DIR:-}" ] && [ -d "$PROFILE_DIR" ]; then
        break
    fi
    sleep 1
done

if [ -z "${PROFILE_DIR:-}" ] || [ ! -d "$PROFILE_DIR" ]; then
    echo "Mullvad profile not found"
    pkill -f mullvad || true
    exit 1
fi

# stop Mullvad cleanly enough for scripting purposes
pkill -f mullvad || true
sleep 2

cp "config/mullvad-pref.js" "$PROFILE_DIR/user.js"


# bashrc (overwrites)
cp -a "bashrc" "$HOME/.bashrc"

# themes + themed configs
cp -a "config/xfce4/."     "$HOME/.config/xfce4/" || true
cp -a "config/gtk-3.0/."   "$HOME/.config/gtk-3.0/" || true
cp -a "config/gtk-4.0/."   "$HOME/.config/gtk-4.0/" || true
cp -a "config/QtProject.conf" "$HOME/.config/QtProject.conf" || true
cp -a "config/copyq/."     "$HOME/.config/copyq/" || true
cp -a "config/galculator/." "$HOME/.config/galculator/" || true
cp -a "config/kcalcrc"     "$HOME/.config/kcalcrc" || true
cp -a "config/qt6ct/" "$HOME/.config/qt6ct/" || true

# --- icons/themes system-wide ---
if have 7z; then
  [[ -f "candy-icons.7z" ]] || die "candy-icons.7z not found in $REPO"
  rm -rf candy-icons
  7z x "candy-icons.7z" -o"$REPO" >/dev/null
  [[ -d "candy-icons" ]] || die "Expected candy-icons/ after extraction"
  sudo cp -a "candy-icons" "/usr/share/icons/"
else
  die "7z not installed. Install with: sudo apt-get install -y p7zip-full"
fi

sudo cp -a "config/Sweet-Dark-v40" "/usr/share/themes/"

# --- make scripts executable (robust) ---
chmod +x "$HOME/.config/i3/autostart.sh" || true
chmod +x "$HOME/.config/i3blocks/cpu/cpu_info.sh" || true
chmod +x "$HOME/.config/i3blocks/battery/battery_info.sh" || true
chmod +x "$HOME/.config/i3blocks/weather/weather.sh" || true
chmod +x "$HOME/.config/i3blocks/weather/weather.py" || true
find "$HOME/scripts" -maxdepth 1 -type f -name "*.sh" -exec chmod +x {} +

# --- defaults (needs desktop session) ---
if have xdg-mime; then
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS-}" ]]; then
    if have mirage; then
      MIRAGE_DESKTOP="mirage.desktop"
      xdg-mime default "$MIRAGE_DESKTOP" image/jpeg image/png image/webp image/gif image/bmp image/tiff
    else
      echo "Note: Mirage not installed (sudo apt-get install -y mirage)"
    fi

    if have vlc; then
      VLC_DESKTOP="vlc.desktop"
      xdg-mime default "$VLC_DESKTOP" video/mp4 video/x-matroska video/x-msvideo video/x-flv video/webm \
                                   audio/mpeg audio/x-wav audio/x-flac audio/ogg audio/mp4
    else
      echo "Note: VLC not installed (sudo apt-get install -y vlc)"
    fi
  else
    echo "Note: No desktop session DBus detected; skipping xdg-mime defaults."
  fi
else
  echo "Note: xdg-mime not found; install with: sudo apt-get install -y xdg-utils"
fi

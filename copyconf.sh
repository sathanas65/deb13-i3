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

# --- pick bare-metal vs VM display outputs in the i3 config -------------
# config/i3/config ships with two switchable blocks: one for bare metal
# (real display outputs, e.g. HDMI-0) and one for a VM (Virtual-1/2/3).
# This turns on whichever one matches how this machine is actually running,
# by commenting out the other block, and leaves everything else in the
# file untouched - including any output names you've already customized.
I3_CONFIG="$HOME/.config/i3/config"

detect_virt() {
    local v
    v="$(systemd-detect-virt --vm 2>/dev/null)" || true
    echo "${v:-none}"
}

# set_i3_display_block <range-start-pattern> <range-end-pattern> <1=turn on | 0=turn off>
set_i3_display_block() {
    local start="$1" end="$2" on="$3"
    # '@' (not '/') delimits the address here, since $end contains a '/'
    # (a plain '/' delimiter would end the address early at that slash)
    if [[ "$on" == 1 ]]; then
        # remove the leading # from every line in this block except the
        # human-readable "uncomment below" comment itself
        sed -i -E "\\@$start@,\\@$end@{ /^#for (bare metal|kvm-qemu guest) install/! { /^#/ s/^#// } }" "$I3_CONFIG"
    else
        # add a leading # to every line in this block except that comment
        sed -i -E "\\@$start@,\\@$end@{ /^#for (bare metal|kvm-qemu guest) install/! { /^#/! s/^/#/ } }" "$I3_CONFIG"
    fi
}

configure_i3_display_mode() {
    [[ -f "$I3_CONFIG" ]] || return 0
    local virt on_vm=0 on_bare=0
    virt="$(detect_virt)"
    if [[ "$virt" == none ]]; then
        on_bare=1
        echo "No virtual machine detected - using the bare-metal display config in ~/.config/i3/config."
        echo "Run 'xrandr -q' after logging in and edit the three 'set \$display_output_*' lines to match your outputs."
    else
        on_vm=1
        case "$virt" in
            kvm|qemu)  virt="KVM/QEMU" ;;
            oracle)    virt="VirtualBox" ;;
            xen)       virt="Xen" ;;
            vmware)    virt="VMware" ;;
            microsoft) virt="Hyper-V" ;;
        esac
        echo "Detected a $virt virtual machine - using the VM display config (Virtual-1/2/3) in ~/.config/i3/config."
        echo "If your hypervisor names its displays differently, check with 'xrandr -q' after logging in."
    fi
    set_i3_display_block "^#for bare metal install"    'config\.d/baremetal\.conf$' "$on_bare"
    set_i3_display_block "^#for kvm-qemu guest install" 'config\.d/vmguest\.conf$'   "$on_vm"
}

configure_i3_display_mode

# terminals
cp -a "config/terminator/." "$HOME/.config/terminator/" || true
cp -a "config/konsole/."    "$HOME/.local/share/konsole/" || true
cp -a "config/konsolerc"    "$HOME/.config/konsolerc" || true

# dashboard
cp -a "config/bpytop/."     "$HOME/.config/bpytop/" || true
cp -a "config/hyfetch.json" "$HOME/.config/hyfetch.json" || true

# geany
# geany.conf is the piece that was missing: it's what actually sets
# color_scheme=delt-dark.conf, so without it Geany just falls back to its
# default (light) theme. install.sh clones the full upstream geany-themes
# repo into ~/.config/geany/colorschemes/ for a wide choice of schemes;
# this layers delt-dark.conf (our custom one, not part of that upstream
# repo) on top without disturbing the others.
mkdir -p "$HOME/.config/geany/colorschemes"
cp -a "config/geany/geany.conf"          "$HOME/.config/geany/geany.conf" || true
cp -a "config/geany/colorschemes/."      "$HOME/.config/geany/colorschemes/" || true

# browsers
#apt Brave
cp -a "config/BraveSoftware/."     "$HOME/.config/BraveSoftware/" || true
#flatpak Brave
mkdir -p "$HOME/.var/app/com.brave.Browser/config/"
cp -a "config/BraveSoftware/."     "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/" || true
#chromium
cp -a "config/chromium/."     "$HOME/.config/chromium/" || true
#mullvad
# Only if Mullvad Browser is actually installed - otherwise there's no
# profile to configure, and launching a browser that doesn't exist would
# stop the whole script (set -euo pipefail).
if have mullvad-browser; then
    PROFILE_ROOT="$HOME/.mullvad-browser/.mullvad/mullvadbrowser"
    PROFILE_DIR=""

    # launch once, headless, so it creates its default profile folder
    mullvad-browser --headless >/dev/null 2>&1 &
    MB_PID=$!

    # wait up to 20 seconds for the profile directory to appear
    for _ in {1..20}; do
        PROFILE_DIR=$(find "$PROFILE_ROOT" -maxdepth 1 -type d -name '*.default-release' 2>/dev/null | head -n1 || true)
        if [ -n "$PROFILE_DIR" ] && [ -d "$PROFILE_DIR" ]; then
            break
        fi
        sleep 1
    done

    # stop the headless instance cleanly enough for scripting purposes.
    # "mullvad-browser" (not just "mullvad") so this can't also kill the
    # separate Mullvad VPN app if that's installed too.
    kill "$MB_PID" 2>/dev/null || true
    pkill -f mullvad-browser || true
    sleep 2

    if [ -n "$PROFILE_DIR" ] && [ -d "$PROFILE_DIR" ]; then
        cp "config/mullvad-pref.js" "$PROFILE_DIR/user.js"
    else
        echo "Note: couldn't find the Mullvad Browser profile folder - skipping its preferences."
    fi
else
    echo "Note: Mullvad Browser isn't installed - skipping its preferences."
fi


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

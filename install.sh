#!/bin/bash
# =====================================================================
#  deb13-i3 installer
#
#  Run with:   bash install.sh 2>&1 | tee install.log
#
#  This file installs the BASE system - everything the i3 desktop needs.
#  Optional apps are NOT listed here. They are in optional-apps.sh and
#  you pick them from a menu when this script starts.
#
#  Options:
#     --defaults   skip the menu (installs only the VM guest tools, when in a VM)
#     --help       show this help
# =====================================================================

# stop on errors
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
USER="${USER:-$(id -un)}"

source "$REPO_DIR/app-picker.sh"
load_apps "$REPO_DIR/optional-apps.sh"

USE_MENU=1
for arg in "$@"; do
    case "$arg" in
        --defaults) USE_MENU=0 ;;
        -h|--help)  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)          echo "Unknown option: $arg  (try --help)" >&2; exit 1 ;;
    esac
done

# reset sudo clock every 60 seconds so you only have to enter password once
sudo -v
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null' EXIT

# ---------------------------------------------------------------------
#  Pick optional apps first, so the rest can run without you
# ---------------------------------------------------------------------
if [ "$USE_MENU" -eq 1 ] && have_tty; then
    choose_apps defaults
    clear >/dev/tty 2>/dev/null || true
else
    echo "No menu - no optional apps except VM guest tools (if this is a VM)."
    select_defaults
fi
print_selection

#TODO

#winboat
#waydroid
#wazuh

sudo apt-get update && sudo apt-get upgrade -y

# tools needed to add repos and download installers
sudo apt-get install -y apt-transport-https curl wget ca-certificates gpg

# ---------------------------------------------------------------------
#  Enable contrib, non-free and non-free-firmware repos
# ---------------------------------------------------------------------
enable_nonfree() {
  local deb822_primary="/etc/apt/sources.list.d/debian.sources"

  _enable_deb822_file() {
    # $1 = .sources file
    # Idempotent: append missing components only; never duplicates.
    sudo sed -i -E '
      /^Components:[[:space:]]/{
        s/[[:space:]]+/ /g
        /(^|[[:space:]])main([[:space:]]|$)/{
          /(^|[[:space:]])contrib([[:space:]]|$)/! s/$/ contrib/
          /(^|[[:space:]])non-free([[:space:]]|$)/! s/$/ non-free/
          /(^|[[:space:]])non-free-firmware([[:space:]]|$)/! s/$/ non-free-firmware/
        }
      }
    ' "$1"
  }

  _enable_classic_sources_list() {
    # /etc/apt/sources.list
    # Idempotent: append missing components at end of matching deb lines.
    sudo sed -i -E '
      /^deb(\s+\[[^]]+\])?\s+/{
        s/[[:space:]]+/ /g
        /(^|[[:space:]])main([[:space:]]|$)/{
          /(^|[[:space:]])contrib([[:space:]]|$)/! s/$/ contrib/
          /(^|[[:space:]])non-free([[:space:]]|$)/! s/$/ non-free/
          /(^|[[:space:]])non-free-firmware([[:space:]]|$)/! s/$/ non-free-firmware/
        }
      }
    ' /etc/apt/sources.list
  }

  if [[ -f "$deb822_primary" ]]; then
    _enable_deb822_file "$deb822_primary"

  elif compgen -G "/etc/apt/sources.list.d/*.sources" >/dev/null; then
    # Fallback deb822: only touch Debian-ish .sources files
    local f
    for f in /etc/apt/sources.list.d/*.sources; do
      if sudo grep -Eq '^URIs:[[:space:]]*(https?://)?(deb\.debian\.org|security\.debian\.org|ftp\.[a-z]+\.(debian\.org|debian\.net))/' "$f"; then
        _enable_deb822_file "$f"
      fi
    done

  else
    _enable_classic_sources_list
  fi
}

enable_nonfree

# Hard-fail during testing:
# - If deb822 primary exists, require non-free-firmware to be present
# - Else (classic), require non-free-firmware to be present on at least one deb line containing main
if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
  sudo grep -qE '^Components:.*(^|[[:space:]])non-free-firmware([[:space:]]|$)' /etc/apt/sources.list.d/debian.sources
else
  sudo grep -qE '^deb(\s+\[[^]]+\])?\s+.*(^|[[:space:]])main([[:space:]]|$).*non-free-firmware' /etc/apt/sources.list
fi

sudo apt-get update

# ---------------------------------------------------------------------
#  Base system (required - the desktop depends on these)
# ---------------------------------------------------------------------

# Policy kit (to launch apps that require root)
sudo apt-get install -y polkitd pkexec lxpolkit

# terminal text editor
# VIM is required for keymap to work out of the box
sudo apt-get install -y vim

# network manager
sudo apt-get install -y network-manager-gnome

# appearance managers
sudo apt-get install -y lxappearance picom

# Flatpak containerized apps platform (flatpak apps in the menu need this)
sudo apt-get install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# terminal emulator
# terminator (dot files included, used for keychord config edits)
# Installed before nemo: nemo's recommended packages want a terminal, and if
# none is installed yet apt picks one on its own (zutty).
sudo apt-get install -y terminator

# file manager
# --no-install-recommends skips ~400 extras nemo would otherwise pull in
# (help viewer + web engine, video codecs, document search helpers...).
# The pieces nemo actually needs are listed by hand:
#   udisks2         - mount drives
#   gvfs-backends   - network shares, phones, cameras, trash
#   nemo-fileroller - right-click compress / extract
# Also listed because the desktop uses them and they used to arrive only as
# nemo extras:
#   x11-xserver-utils - xrandr, xset (display scripts, login screen, caps indicator)
#   psmisc            - killall (keybinds)
#   xdg-utils         - xdg-open, xdg-mime (opening links/files, default apps)
sudo apt-get install -y --no-install-recommends nemo udisks2 gvfs-backends nemo-fileroller \
    x11-xserver-utils psmisc xdg-utils

# settings interface
sudo apt-get install -y xfce4-settings xfce4-power-manager

# Network File Tools/System Events
sudo apt-get install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends
sudo systemctl enable avahi-daemon
sudo systemctl enable acpid

# tmux - terminal multiplexer - runs in terminal and shell sessions run in tmux - excellent features
sudo apt-get install -y tmux

# audio
sudo apt-get install -y pipewire pipewire-pulse wireplumber pipewire-alsa alsa-utils

# calculator (galculator is customized)
sudo apt-get install -y galculator

# background / image manager
sudo apt-get install -y feh

# app launcher ($mod + Space)
sudo apt-get install -y rofi

# Chromium is required: Super + F1 opens the NordVPN login page with it, and
# it's the fallback browser for anything opened before you've picked one in
# the app menu. (Edit ~/scripts/nordvpn.sh if you'd rather use another browser
# for the NordVPN login.)
sudo apt-get install -y chromium

# auto numlock
sudo apt-get install -y numlockx

# notification daemon
sudo apt-get install -y dunst libnotify-bin

# user dialog
sudo apt-get install -y yad

# gui text editor - geany with color schemes
sudo apt-get install -y geany geany-plugins
mkdir -p "$HOME/.config/geany/colorschemes"
rm -rf /tmp/geany-themes
git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
cp /tmp/geany-themes/colorschemes/* "$HOME/.config/geany/colorschemes/"

# clipboard manager
sudo apt-get install -y copyq

# screenshots
sudo apt-get install -y maim xclip xdotool jq

# zip utilities
sudo apt-get install -y tar gzip p7zip-full

# user directories (disable this if you want many things to not work. There will be weeping and gnashing of teeth)
xdg-user-dirs-update

# These are required for the theme and icons to work and i3bar to display correctly
sudo apt-get install -y libgtk-4-dev
sudo apt-get install -y fonts-noto-color-emoji

# ---------------------------------------------------------------------
#  Optional apps - the ones you ticked in the menu
#  (the list and install steps are in optional-apps.sh)
# ---------------------------------------------------------------------
install_selected_apps

# create ~/.local/share/applications/ to support executables and snaps in Rofi
if [ -d /var/lib/snapd/desktop/applications ]; then
	mkdir -p "$HOME/.local/share/applications"
	for f in /var/lib/snapd/desktop/applications/*.desktop; do
	  [ -e "$f" ] || continue
	  ln -sf "$f" "$HOME/.local/share/applications/$(basename "$f")"
	done
	update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

# ---------------------------------------------------------------------
#  Graphical user interface
# ---------------------------------------------------------------------

# window manager DO NOT REMOVE
sudo apt-get install -y i3 i3blocks acpi-support python3-i3ipc

# display manager DO NOT Remove
sudo apt-get install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

# import scripts and configs
bash "$REPO_DIR/copyconf.sh"

# This makes lightdm greeter login screen set display to 1080p on kvm-qemu guest vm and sets the background for the login screen -
# After first boot, you can modify display.sh value "Virtual-1" to your display output
# Get display outputs with $  xrandr -q
# Physical display outputs are HDMI-0, VGA-0, DP-0, DVI-D-0, HDMI-1, etc.
sudo cp "$REPO_DIR/display.sh" /usr/share/display.sh
sudo chown root:root /usr/share/display.sh
sudo chmod 775 /usr/share/display.sh
sudo cp "$REPO_DIR/background.png" /usr/share/background.png
sudo chown root:root /usr/share/background.png
sudo chmod 644 /usr/share/background.png
sudo cp "$REPO_DIR/01_debian.conf" /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf
sudo chown root:root /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf
sudo chmod 644 /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf
sudo cp "$REPO_DIR/lightdm.conf" /etc/lightdm/lightdm.conf
sudo chown root:root /etc/lightdm/lightdm.conf
sudo chmod 644 /etc/lightdm/lightdm.conf

sudo systemctl enable lightdm

# This allows checking firewall status without password - used in firewall scripts
echo "$USER ALL=(ALL) NOPASSWD: /usr/sbin/ufw status" | sudo tee /etc/sudoers.d/ufw-status
sudo chmod 0440 /etc/sudoers.d/ufw-status

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get autoremove -y

# ---------------------------------------------------------------------
#  Let NetworkManager manage your network connections
# ---------------------------------------------------------------------
# Debian's installer lists your network interface in /etc/network/interfaces.
# NetworkManager (installed above) then treats that interface as "unmanaged":
# its applet can't connect to any other network - only the one you set up
# during install keeps working. This hands the interface over to
# NetworkManager by commenting it out there, leaving the loopback interface
# (needed for the system to work at all) untouched. It only edits a file -
# nothing is applied live - so it can't interrupt this script, including over
# SSH; the change takes effect at the reboot below.
configure_networkmanager_interfaces() {
    local f=/etc/network/interfaces anchor='# The primary network interface'
    [ -f "$f" ] || return 0
    sudo grep -qxF "$anchor" "$f" || {
        echo "Note: couldn't find the usual network interface setup in $f - leaving it as-is."
        echo "See the install guide's networking section if NetworkManager can't connect to other networks."
        return 0
    }

    # already done (a previous run, or a manual edit) - nothing to change
    sudo sed -n "/^${anchor}\$/,\$p" "$f" | sudo grep -Eqv '^#|^[[:space:]]*$' || return 0

    # keep the very first backup - never overwrite it on a later run
    sudo cp -n "$f" "$f.bkp"

    # comment out every real line from that point on (not the anchor itself,
    # not lines already commented, not blank lines)
    sudo sed -i -E "/^${anchor}\$/,\$ { /^${anchor}\$/! { /^#/! { /^[[:space:]]*\$/! s/^/#/ } } }" "$f"
    echo "Handed your network interface over to NetworkManager in $f (backup saved as $f.bkp)."
}
configure_networkmanager_interfaces

# list any optional apps that failed (waits for Enter if there were any)
report_failures "$REPO_DIR/failed-apps.txt" || true

sudo reboot now

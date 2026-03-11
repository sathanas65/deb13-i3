#!/bin/bash

## on error 
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

## reset sudo clock every 60 seconds so you only have to enter password once
sudo -v
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null' EXIT

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

install_uncomplicated_firewall() {
	sudo apt-get install -y ufw
	sudo ufw --force enable
}

sudo apt-get update && sudo apt-get upgrade -y

# enable non-free repos
sudo apt-get install -y apt-transport-https curl ca-certificates gpg
#set -e

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

# Hard-fail during testing:
# - If deb822 primary exists, require non-free-firmware to be present
# - Else (classic), require non-free-firmware to be present on at least one deb line containing main
if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
  sudo grep -qE '^Components:.*(^|[[:space:]])non-free-firmware([[:space:]]|$)' /etc/apt/sources.list.d/debian.sources
else
  sudo grep -qE '^deb(\s+\[[^]]+\])?\s+.*(^|[[:space:]])main([[:space:]]|$).*non-free-firmware' /etc/apt/sources.list
fi

sudo apt-get update

# Enable easy external repo adds/signing
sudo apt-get install extrepo -y

# Policy kit (to launch apps that require root)
sudo apt-get install -y polkitd pkexec lxpolkit

# terminal text editor
# VIM is required for keymap to work out of the box
sudo apt-get install -y vim

# network manager
sudo apt-get install -y network-manager-gnome

# appearance managers
sudo apt-get install -y lxappearance picom 

install_flatpak() {
	sudo apt-get install -y flatpak
	sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_snap() {
	# snap store (Supports installation of containerized apps)
	sudo apt-get install -y snapd
	sleep 10
	sudo snap install core
	# schedule snap updates daily between 2 and 4 am
	sudo snap set core refresh.schedule=02:00-04:00
}

# terminal file search
sudo apt-get install -y fzf

# terminal list directory (on steroids)
sudo apt-get install -y eza

# settings interface
sudo apt-get install -y xfce4-settings xfce4-power-manager

# Network File Tools/System Events
sudo apt-get install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends
sudo systemctl enable avahi-daemon
sudo systemctl enable acpid

# terminal emulators
# terminator (dot files included)
sudo apt-get install -y terminator
# kitty (no dot files yet)
#sudo apt-get install -y kitty 
# konsole (required for out of box use of:
# Super + Shift + h for keymap and 
# Super + Shift + i for backup and edit i3 config and
# Super + n then s for nordvpn status)
#sudo apt-get install -y konsole
#sudo apt-get install -y xterm
#sudo apt-get install -y zutty

# tmux - terminal multiplexer - runs in terminal and shell sessions run in tmux - excellent features
sudo apt-get install -y tmux


# terminal apps  
# leave these or the dashboard won't work, can disable dashboard in i3 workspace config
sudo apt-get install -y bpytop cmatrix hyfetch
sleep 5
neowofetch --generate_config 2>/dev/null || true
sed -i 's/^color_blocks="on"/color_blocks="off"/' ~/.config/neowofetch/config.conf

install_cups() {
	sudo apt-get install -y cups
	sudo systemctl enable cups
}

install_bt() {
	sudo apt-get install -y bluez blueman
	sudo systemctl enable bluetooth
}

#galculator is customized
sudo apt-get install -y galculator

install_apt_brave() {
	sudo extrepo enable brave_release
	sudo apt update
	sudo apt install brave-browser
}

install_flatpak_brave() {
	flatpak install -y flathub com.brave.Browser
	mkdir -p ~/.var/app/com.brave.Browser/config/
	flatpak install -y flathub runtime/org.gtk.Gtk3theme.Plata-Noir/x86_64/3.22
	flatpak install -y flathub runtime/org.gtk.Gtk3theme.Plata-Noir/x86_64/3.24
	flatpak override --user --env=GTK_THEME=Plata-Noir com.brave.Browser
}

install_librewolf() {
	sudo extrepo enable librewolf
	sudo apt-get update && sudo apt-get install librewolf -y
}

install_mullvad() {
	sudo extrepo enable mullvad
	sudo apt update
	sudo apt install mullvad-browser
}

install_tor() {
	sudo apt-get install -y torbrowser-launcher 
}

install_dangerzone() {
	sudo mkdir -p /etc/apt/keyrings
	sudo gpg --keyserver hkps://keys.openpgp.org \
		--no-default-keyring --no-permission-warning --homedir $(mktemp -d) \
		--keyring gnupg-ring:/etc/apt/keyrings/fpf-apt-tools-archive-keyring.gpg \
		--recv-keys DE28AB241FA48260FAC9B8BAA7C9B38522604281
	sudo chmod +r /etc/apt/keyrings/fpf-apt-tools-archive-keyring.gpg
	. /etc/os-release
	echo "deb [signed-by=/etc/apt/keyrings/fpf-apt-tools-archive-keyring.gpg] \
		https://packages.freedom.press/apt-tools-prod ${VERSION_CODENAME?} main" \
		| sudo tee /etc/apt/sources.list.d/fpf-apt-tools.list
	sudo apt-get update
	sudo apt-get install -y dangerzone 
}

# background / image manager
sudo apt-get install -y feh

# app launcher ($mod + Space)
sudo apt-get install -y rofi

# auto numlock
sudo apt-get install -y numlockx

# notification daemon
sudo apt-get install -y dunst libnotify-bin

# user dialog
sudo apt-get install -y yad

install_geany() {
	sudo apt-get install -y geany geany-plugins
	mkdir -p "$HOME/.config/geany/colorschemes"
	git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
	cp /tmp/geany-themes/colorschemes/* "$HOME/.config/geany/colorschemes/"
}

install_codecs() {
	sudo apt-get install -y ttf-mscorefonts-installer libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly
}

# zip utilities
sudo apt-get install -y tar gzip p7zip-full

install_anydesk() {
	sudo extrepo enable anydesk
	sudo apt update
	sudo apt install anydesk
}

install_teamviewer() {
	sudo extrepo enable teamviewer_default
	sudo apt update
	sudo apt install teamviewer
}

install_veracrypt_cli() {
	cd /tmp
	wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-console-1.26.24-Debian-12-amd64.deb
	wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-console-1.26.24-Debian-12-amd64.deb.sig
	wget https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc
	gpg --show-keys VeraCrypt_PGP_public_key.asc
	gpg --import VeraCrypt_PGP_public_key.asc
	gpg --verify veracrypt-console-1.26.24-Debian-12-amd64.deb.sig \
				 veracrypt-console-1.26.24-Debian-12-amd64.deb
	sudo apt-get install -y ./veracrypt-console-1.26.24-Debian-12-amd64.deb
}

install_veracrypt_gui() {
	cd /tmp
	wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Debian-12-amd64.deb
	wget https://launchpad.net/veracrypt/trunk/1.26.24/+download/veracrypt-1.26.24-Debian-12-amd64.deb.sig
	wget https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc
	gpg --show-keys VeraCrypt_PGP_public_key.asc
	gpg --import VeraCrypt_PGP_public_key.asc
	gpg --verify veracrypt-1.26.24-Debian-12-amd64.deb.sig \
				 veracrypt-1.26.24-Debian-12-amd64.deb
	sudo apt-get install -y ./veracrypt-1.26.24-Debian-12-amd64.deb
}

install_kdeconnect() {
	sudo apt-get install -y kdeconnect
	# enable dark theme for KDE applets
	bash "$HOME/deb13-i3/kdeTheme.sh"
	# disable kwallet (Brave is annoying when it is active)
	sudo mv /usr/share/dbus-1/services/org.kde.kwalletd6.service \
			/usr/share/dbus-1/services/org.kde.kwalletd6.service.disabled

	sudo mv /usr/share/dbus-1/services/org.kde.kwalletd5.service \
			/usr/share/dbus-1/services/org.kde.kwalletd5.service.disabled
}

install_signal() {
	sudo extrepo enable signal
	sudo apt update
	sudo apt install signal-desktop
}

install_steam() {
	sudo dpkg --add-architecture i386
	sudo apt-get update
	sudo apt-get install -y steam
}

install_vscode() {
	sudo extrepo enable vscode
	sudo apt update
	sudo apt install code
}

install_vscodium() {
	sudo extrepo enable vscodium
	sudo apt update
	sudo apt install codium
}

install_pycharm() {
	curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
	echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y pycharm-community
}

# user directories (disable this if you want many things to not work. There will be weeping and gnashing of teeth)
xdg-user-dirs-update

install_nordvpn() {
	curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh -o nordvpn_install.sh
	sh nordvpn_install.sh
	sudo usermod -aG nordvpn $USER
}
	
install_mullvadvpn() {
	sudo extrepo enable mullvad
	sudo apt update
	sudo apt install mullvad-vpn
}

install_bleachbit() {
	sudo apt-get -y install bleachbit
	mkdir -p "$HOME/.local/bin"
	mkdir -p "$HOME/.local/share/applications"
	# wrapper script for reliable root launch from rofi/drun
	cat > "$HOME/.local/bin/bleachbit-root" <<'EOF'	
#!/bin/bash
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
exec /usr/bin/env sh -lc 'pkexec /usr/bin/bleachbit'
EOF
	  chmod +x "$HOME/.local/bin/bleachbit-root"
	  # desktop entry so rofi can see it
	  cat > "$HOME/.local/share/applications/bleachbit-root.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=BleachBit (Root)
Exec=$HOME/.local/bin/bleachbit-root
Icon=bleachbit
Terminal=false
Categories=System;
NoDisplay=false
EOF
	  # clear rofi cache so the new launcher appears
	  rm -f "$HOME/.cache/rofi2.druncache" \
			"$HOME/.cache/rofi3.druncache" \
			"$HOME"/.cache/rofi-*.cache 2>/dev/null || true
}

# These are required for the theme and icons to work and i3bar to display correctly
sudo apt-get install -y libgtk-4-dev
sudo apt-get install -y fonts-noto-color-emoji 

install_virt_manager() {
	sudo apt-get install -y virt-manager cockpit-machines cockpit-podman distrobox
	sudo addgroup libvirt
	sudo addgroup kvm
	sudo usermod -aG libvirt $(whoami)
	sudo usermod -aG kvm $(whoami)
}

# create ~/.local/share/applications/ to support executables and snaps in Rofi
if [ -d /var/lib/snapd/desktop/applications ]; then
	mkdir -p "$HOME/.local/share/applications"
	for f in /var/lib/snapd/desktop/applications/*.desktop; do
	  [ -e "$f" ] || continue
	  ln -sf "$f" "$HOME/.local/share/applications/$(basename "$f")"
	done
	update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

### graphical user interface

# window manager DO NOT REMOVE
sudo apt-get install -y i3 i3blocks acpi-support python3-i3ipc

# display manager DO NOT Remove
sudo apt-get install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings


# import scripts and configs
bash "$REPO_DIR/copyconf.sh"

# This makes lightdm greeter login screen set display to 1080p on kvm-qemu guest vm and sets the background for the login screen - 
# Keep these commented if installing on hardware. After first boot, you can modify display.sh value "Virtual-1" to your display output
# Get display outputs with $  xarandr -q
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
echo 'user ALL=(ALL) NOPASSWD: /usr/sbin/ufw status' | sudo tee /etc/sudoers.d/ufw-status
sudo chmod 0440 /etc/sudoers.d/ufw-status

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get autoremove -y

sudo reboot now



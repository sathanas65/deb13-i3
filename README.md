Debian 13 - i3 Window Manager
===================
This repo hosts a set of install scripts and config files for Debian 13, to automate installation and configuration of the i3 Window Manager and other packages. You will be prompted to select desired applications at run time. A full list of included apps is at the bottom of this document. For best results, install on a fresh Debian 13 with no GUI environment. 

I created this repo to archive and automate my own install process. My goal was to assemble a set of packages and scripts that would provide an attractive and efficient workflow, aimed primarily at those who avoid using the mouse, and those who want to maximize fine tuned control of their system. I chose i3 for it's ease of use and modest learning curve. 

I want a minimal UI that provides exactly what is required, without installing a bloated or more limited desktop environment or a derivitive distribution with packages I do not need or want. I like a dark UI, but with some colorful accents.

Some non-FOSS packages are included. My goal is to use FOSS wherever practical. I welcome suggestions for FOSS alternatives.

Still in progress: scrcpy 2.0, mullvad vpn scripts, peazip, cryptomator, winboat, waydroid.

Next up: Debian 14 - sway. 

Documentation
-------------
* [Install Guide](https://github.com/sathanas65/deb13-i3/blob/main/Docs/Installation.md)    * [Default Keybinds](https://github.com/sathanas65/deb13-i3/blob/main/scripts/keymap.txt)    * [Install Script](https://github.com/sathanas65/deb13-i3/blob/main/install.sh)

![GitHub Image](/screenshots/screenshot-20260308-030032Z.png)      ![GitHub Image](/screenshots/screenshot-20260308-025921Z.png)

![GitHub Image](/screenshots/screenshot-20260308-025502Z.png) 

## Installed Packages

### Always installed (base system)

| Package | Purpose |
|---|---|
| i3, i3blocks, python3-i3ipc | Window manager and status bar |
| lightdm, lightdm-gtk-greeter, lightdm-gtk-greeter-settings | Display / login manager |
| picom | Compositor (transparency, shadows) |
| lxappearance | GTK theme selector |
| rofi | Application launcher |
| dunst, libnotify-bin | Notification daemon |
| nemo, nemo-fileroller | File manager with archive support |
| udisks2, gvfs-backends | Drive mounting support |
| terminator | Terminal emulator |
| chromium | Browser (also used for NordVPN login keybind) |
| geany, geany-plugins | Text editor / lightweight IDE |
| copyq | Clipboard manager |
| galculator | Calculator |
| feh | Wallpaper setter |
| yad | Dialog boxes (used by scripts) |
| network-manager-gnome | NetworkManager tray applet (nm-applet) |
| pipewire, pipewire-pulse, wireplumber, pipewire-alsa, alsa-utils | Audio |
| flatpak | Flatpak app container runtime |
| qt6ct | Qt6 theme configurator |
| xdg-desktop-portal, xdg-desktop-portal-gtk | Portal for Flatpak dark-mode detection |
| gsettings-desktop-schemas, dconf-gsettings-backend, libglib2.0-bin | GSettings / dark-mode portal backend |
| xfce4-settings, xfce4-power-manager | Power management and settings daemon |
| polkitd, pkexec, lxpolkit | Privilege escalation (sudo GUI prompts) |
| numlockx | Enable numlock on login |
| maim, xclip, xdotool, jq | Screenshot and scripting utilities |
| tmux | Terminal multiplexer |
| vim | Terminal text editor |
| curl, wget, ca-certificates, gpg, apt-transport-https | Download and repo tools |
| dialog, mtools, dosfstools, avahi-daemon, acpi, acpid | System utilities |
| tar, gzip, p7zip-full | Archiving (p7zip needed to extract candy-icons) |
| fonts-noto-color-emoji | Emoji font |
| libgtk-4-dev | GTK4 development headers (theming support) |
| acpi-support, acpid | Power/lid/sleep events |

---

### System

| App | Package | Install method |
|---|---|---|
| Firewall | ufw | apt |
| Snap store | snapd | apt |
| Hardware info | hwinfo, lm-sensors, hdparm, psensor, procinfo | apt |
| GNOME System Monitor | gnome-system-monitor | apt |
| Synaptic | synaptic | apt |
| Printer support | cups | apt |
| Bluetooth | bluez, blueman | apt |
| Cockpit | cockpit | apt |
| ARandR | arandr | apt |
| SPICE guest agent *(auto-ticked in KVM/QEMU)* | spice-vdagent | apt |
| VirtualBox Guest Additions *(auto-ticked in VirtualBox)* | virtualbox-guest-x11 | apt (via Fasttrack repo) |

---

### Terminal tools

| App | Package | Install method |
|---|---|---|
| fzf | fzf | apt |
| eza | eza | apt |
| bpytop | bpytop | apt |
| cmatrix | cmatrix | apt |
| hyfetch | hyfetch | apt |
| htop | htop | apt |
| glances | glances | apt |
| figlet | figlet | apt |
| calc | calc | apt |
| tealdeer | tealdeer | apt |
| Midnight Commander | mc | apt |

---

### Terminals

| App | Package | Install method |
|---|---|---|
| Kitty | kitty | apt |
| Konsole | konsole | apt |
| XTerm | xterm | apt |
| Zutty | zutty | apt |

*(Terminator is always installed)*

---

### File managers

| App | Package | Install method |
|---|---|---|
| Thunar | thunar | apt |
| Krusader | krusader | apt |
| Nautilus | nautilus | apt |

*(Nemo is always installed)*

---

### Browsers

| App | Package | Install method |
|---|---|---|
| Brave | brave-browser | apt (Brave repo) |
| Brave | com.brave.Browser | Flatpak |
| LibreWolf | librewolf | apt (via extrepo) |
| Tor Browser | torbrowser-launcher | apt |
| Mullvad Browser | mullvad-browser | apt (Mullvad repo) |
| Firefox ESR | firefox-esr | apt |

*(Chromium is always installed)*

---

### Documents & office

| App | Package | Install method |
|---|---|---|
| LibreOffice | libreoffice, libreoffice-gtk3 | apt |
| Evince | evince | apt |
| Foliate | foliate | apt |
| Calibre | com.calibre_ebook.calibre | Flatpak |
| MComix | mcomix | apt |
| Zim | zim | apt |
| VYM | vym | apt |

---

### Media

| App | Package | Install method |
|---|---|---|
| VLC | vlc | apt |
| Audacity | audacity | apt |
| GIMP | gimp | apt |
| Pinta | com.github.PintaProject.Pinta | Flatpak |
| imv | imv | apt |
| Mirage | mirage | apt |
| SimpleScreenRecorder | simplescreenrecorder | apt |
| Kdenlive | kdenlive | apt |
| Shotcut | shotcut | apt |
| FFmpeg | ffmpeg | apt |
| HandBrake | handbrake | apt |
| FreeTube | io.freetubeapp.FreeTube | Flatpak |
| Non-free codecs + MS fonts | ttf-mscorefonts-installer, libavcodec-extra, gstreamer1.0-libav, gstreamer1.0-plugins-ugly | apt |

---

### Email & messaging

| App | Package | Install method |
|---|---|---|
| Evolution | evolution | apt |
| Thunderbird | thunderbird | apt |
| NeoMutt | neomutt | apt |
| Signal | signal-desktop | apt (Signal repo) |

---

### Security & privacy

| App | Package | Install method |
|---|---|---|
| KeePassXC | keepassxc | apt |
| Bitwarden | com.bitwarden.desktop | Flatpak |
| AuthPass | app.authpass.AuthPass | Flatpak |
| pass + OTP | pass, pass-extension-otp | apt |
| Kleopatra | kleopatra | apt |
| VeraCrypt (terminal) | veracrypt-console | apt (VeraCrypt) |
| VeraCrypt (graphical) | veracrypt | apt (VeraCrypt) |
| Dangerzone | dangerzone | apt (Freedom Press repo) |
| GNOME Authenticator | com.belmoussaoui.Authenticator | Flatpak |
| Yubico Authenticator | com.yubico.yubioath + pcscd | Flatpak + apt |
| YubiKey Manager | yubikey-manager, yubikey-manager-qt | apt |
| BleachBit | bleachbit | apt |
| mat2 | mat2 | apt |
| Metadata Cleaner | metadata-cleaner | apt |

---

### Remote & network

| App | Package | Install method |
|---|---|---|
| NordVPN | nordvpn | apt (NordVPN script) |
| Mullvad VPN | mullvad-vpn | apt (Mullvad repo) |
| AnyDesk | anydesk | apt (AnyDesk repo) |
| TeamViewer | teamviewer | apt (downloaded .deb) |
| KDE Connect | kdeconnect | apt |
| Transmission | transmission | apt |
| vsftpd (FTP server) | vsftpd | apt |

---

### Development

| App | Package | Install method |
|---|---|---|
| VS Code | code | apt (Microsoft repo) |
| VSCodium | codium | apt (VSCodium repo) |
| PyCharm | pycharm | apt (community repo) |
| Postman | com.getpostman.Postman | Flatpak |
| Postman CLI | postman | curl installer |
| Android tools (adb, fastboot) | android-sdk-platform-tools-common, adb, fastboot | apt |

---

### Disks & backup

| App | Package | Install method |
|---|---|---|
| GNOME Disks | gnome-disk-utility | apt |
| GSmartControl | gsmartcontrol | apt |
| GParted | gparted | apt |
| Timeshift | timeshift | apt |
| Duplicity | duplicity | apt |

---

### Virtualization

| App | Package | Install method |
|---|---|---|
| Podman | podman | apt |
| Docker | docker.io | apt |
| Distrobox | distrobox | apt |
| KVM/QEMU + virt-manager + Cockpit | qemu-kvm, libvirt-daemon-system, libvirt-clients, bridge-utils, virt-manager, cockpit-machines, cockpit-podman | apt |

---

### Other

| App | Package | Install method |
|---|---|---|
| HomeBank | fr.free.Homebank | Flatpak |
| Steam | steam-installer | apt |
| Kiwix | kiwix | apt |
| Kiwix tools | kiwix-tools | apt |


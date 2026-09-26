#!/bin/bash
# =====================================================================
#  OPTIONAL APPS
# =====================================================================
#  This file is the list of apps offered in the install menu.
#  Nothing in here runs on its own - install.sh reads this file,
#  shows the menu, and installs only the apps that are ticked.
#
#  Every app is ONE block that looks like this:
#
#      app  htop  off  "Terminal tools"  "htop - interactive process viewer"
#      install_htop() {
#          apt_install htop
#      }
#
#  The "app" line has four parts:
#      1. name         short name: letters, numbers and _ only.
#                      The function under it MUST be called install_<name>
#      2. default      on  = ticked in the menu to start with
#                      off = not ticked to start with
#                      kvm = ticked only when installing inside a KVM/QEMU VM
#                      virtualbox = ticked only when installing inside VirtualBox
#      3. "category"   which page of the menu the app shows up on
#                      (a new category name makes a new page)
#      4. "text"       what the person sees in the menu
#
#  The commands between { and } are what gets run to install it.
#
#  Apps are installed in the order they appear in this file.
#
#  To ADD an app:     copy a block, then change the name, text and commands.
#  To REMOVE an app:  delete its whole block.
#  To change what is ticked by default: change on/off.
#
#  Handy shortcuts you can use inside the { }:
#      apt_install  <packages...>       install from Debian
#      flatpak_install  <app id...>     install from Flathub
#
#  To show a note at the top of a category's page, add a line like:
#      category_note  "File managers"  "Your text here."
# =====================================================================

apt_install()     { sudo apt-get install -y "$@"; }
flatpak_install() { sudo flatpak install -y flathub "$@"; }


# ---------------------------------------------------------------------
app  ufw  off  "System"  "Firewall (ufw) - switched on at install"
install_ufw() {
    apt_install ufw
    # keep SSH reachable if an SSH server is installed
    if dpkg -s openssh-server >/dev/null 2>&1; then
        sudo ufw allow OpenSSH
    fi
    sudo ufw --force enable
}

# ---------------------------------------------------------------------
app  snap  off  "System"  "Snap store support (snapd)"
install_snap() {
    apt_install snapd
    sleep 10
    sudo snap install core
    # schedule snap updates daily between 2 and 4 am
    sudo snap set core refresh.schedule=02:00-04:00
}

# ---------------------------------------------------------------------
app  fzf  off  "Terminal tools"  "fzf - fuzzy file search"
install_fzf() {
    apt_install fzf
}

# ---------------------------------------------------------------------
category_note  "File managers"  "Nemo is always installed and themed to match the desktop. Anything you tick here is installed IN ADDITION to Nemo."

app  thunar  off  "File managers"  "Thunar"
install_thunar() {
    apt_install thunar
}

app  krusader  off  "File managers"  "Krusader (two-pane)"
install_krusader() {
    apt_install krusader
}

app  nautilus  off  "File managers"  "Nautilus (GNOME Files)"
install_nautilus() {
    apt_install nautilus
}

# ---------------------------------------------------------------------
app  eza  off  "Terminal tools"  "eza - ls on steroids"
install_eza() {
    apt_install eza
}

# ---------------------------------------------------------------------
category_note  "Terminals"  "Terminator is always installed and themed to match the desktop. Anything you tick here is installed IN ADDITION to Terminator."

app  kitty  off  "Terminals"  "Kitty (no dot files yet)"
install_kitty() {
    apt_install kitty
}

app  konsole  off  "Terminals"  "Konsole"
install_konsole() {
    apt_install konsole
}

app  xterm  off  "Terminals"  "XTerm"
install_xterm() {
    apt_install xterm
}

app  zutty  off  "Terminals"  "Zutty"
install_zutty() {
    apt_install zutty
}

# ---------------------------------------------------------------------
app  hardware_info  off  "System"  "Hardware info tools (hwinfo, lm-sensors, psensor...)"
install_hardware_info() {
    apt_install procinfo hwinfo hdparm lm-sensors psensor
}

# ---------------------------------------------------------------------
app  audacity  off  "Media"  "Audacity - audio editor"
install_audacity() {
    apt_install audacity
}

# ---------------------------------------------------------------------
app  bpytop  off  "Terminal tools"  "bpytop - system monitor"
install_bpytop() {
    apt_install bpytop
}

app  cmatrix  off  "Terminal tools"  "cmatrix - Matrix-style screen effect"
install_cmatrix() {
    apt_install cmatrix
}

app  hyfetch  off  "Terminal tools"  "hyfetch - system info with pride flag colors"
install_hyfetch() {
    apt_install hyfetch
    sleep 5
    # hyfetch needs a neowofetch config; turn off the color blocks
    neowofetch --generate_config 2>/dev/null || true
    if [ -f "$HOME/.config/neowofetch/config.conf" ]; then
        sed -i 's/^color_blocks="on"/color_blocks="off"/' "$HOME/.config/neowofetch/config.conf"
    fi
}

# ---------------------------------------------------------------------
app  htop  off  "Terminal tools"  "htop - process viewer"
install_htop() {
    apt_install htop
}

app  glances  off  "Terminal tools"  "glances - system monitor"
install_glances() {
    apt_install glances
}

app  figlet  off  "Terminal tools"  "figlet - big ASCII text"
install_figlet() {
    apt_install figlet
}

app  calc  off  "Terminal tools"  "calc - terminal calculator"
install_calc() {
    apt_install calc
}

# ---------------------------------------------------------------------
app  system_monitor  off  "System"  "GNOME System Monitor"
install_system_monitor() {
    apt_install gnome-system-monitor
}

# ---------------------------------------------------------------------
app  synaptic  off  "System"  "Synaptic - graphical package manager"
install_synaptic() {
    apt_install synaptic
}

# ---------------------------------------------------------------------
app  printing  off  "System"  "Printer support (CUPS)"
install_printing() {
    apt_install cups
    sudo systemctl enable cups
}

app  bluetooth  off  "System"  "Bluetooth support (bluez + blueman)"
install_bluetooth() {
    apt_install bluez blueman
    sudo systemctl enable bluetooth
}

# ---------------------------------------------------------------------
app  evince  off  "Documents & office"  "Evince - PDF / document viewer"
install_evince() {
    apt_install evince
}

app  foliate  off  "Documents & office"  "Foliate - ebook reader"
install_foliate() {
    apt_install foliate
}

app  calibre  off  "Documents & office"  "Calibre - ebook library (flatpak)"
install_calibre() {
    flatpak_install com.calibre_ebook.calibre
}

app  mcomix  off  "Documents & office"  "MComix - comic reader"
install_mcomix() {
    apt_install mcomix
}

category_note  "Browsers"  "Chromium is always installed (needed for the NordVPN login keybind). Anything you tick here is installed IN ADDITION to Chromium."

# ---------------------------------------------------------------------
# Brave (apt) - NOT FOSS. $mod + b opens it.
# Known bug: Brave may fail to start on the very first launch. Works after a reboot.
app  brave_apt  off  "Browsers"  "Brave (apt) - NOT FOSS"
install_brave_apt() {
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    # remove the old-style repo file if an earlier install left one behind
    sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt-get update
    apt_install brave-browser
}

# Using both apt and flatpak Brave helps keep google and such separate
app  brave_flatpak  off  "Browsers"  "Brave (flatpak) - NOT FOSS"
install_brave_flatpak() {
    flatpak_install com.brave.Browser
    mkdir -p "$HOME/.var/app/com.brave.Browser/config/"
    flatpak_install runtime/org.gtk.Gtk3theme.Plata-Noir/x86_64/3.22
    flatpak_install runtime/org.gtk.Gtk3theme.Plata-Noir/x86_64/3.24
    flatpak override --user --env=GTK_THEME=Plata-Noir com.brave.Browser
}

app  librewolf  off  "Browsers"  "LibreWolf"
install_librewolf() {
    apt_install extrepo
    sudo extrepo enable librewolf
    sudo apt-get update
    apt_install librewolf
}

app  tor_browser  off  "Browsers"  "Tor Browser (launcher)"
install_tor_browser() {
    apt_install torbrowser-launcher
}

app  mullvad_browser  off  "Browsers"  "Mullvad Browser"
install_mullvad_browser() {
    add_mullvad_repo
    apt_install mullvad-browser
}

app  firefox  off  "Browsers"  "Firefox ESR"
install_firefox() {
    apt_install firefox-esr
}

# ---------------------------------------------------------------------
# Dangerzone turns risky PDFs, office documents or images into safe PDFs
# by rendering them to pixels in an offline sandbox and rebuilding the PDF.
app  dangerzone  off  "Security & privacy"  "Dangerzone - make risky documents safe"
install_dangerzone() {
    sudo mkdir -p /etc/apt/keyrings
    sudo gpg --keyserver hkps://keys.openpgp.org \
        --no-default-keyring --no-permission-warning --homedir "$(mktemp -d)" \
        --keyring gnupg-ring:/etc/apt/keyrings/fpf-apt-tools-archive-keyring.gpg \
        --recv-keys DE28AB241FA48260FAC9B8BAA7C9B38522604281
    sudo chmod +r /etc/apt/keyrings/fpf-apt-tools-archive-keyring.gpg
    . /etc/os-release
    echo "deb [signed-by=/etc/apt/keyrings/fpf-apt-tools-archive-keyring.gpg] https://packages.freedom.press/apt-tools-prod ${VERSION_CODENAME} main" \
        | sudo tee /etc/apt/sources.list.d/fpf-apt-tools.list
    sudo apt-get update
    apt_install dangerzone
}

# ---------------------------------------------------------------------
app  imv  off  "Media"  "imv - image viewer"
install_imv() {
    apt_install imv
}

app  mirage  off  "Media"  "Mirage - image viewer"
install_mirage() {
    apt_install mirage
}

# ---------------------------------------------------------------------
# Cockpit admin web console: open https://127.0.0.1:9090/ in a browser
app  cockpit  off  "System"  "Cockpit - admin web console"
install_cockpit() {
    apt_install cockpit
}

app  libreoffice  off  "Documents & office"  "LibreOffice"
install_libreoffice() {
    apt_install libreoffice
}

app  arandr  off  "System"  "ARandR - display settings"
install_arandr() {
    apt_install arandr
}

app  vlc  off  "Media"  "VLC media player"
install_vlc() {
    apt_install vlc
}

app  codecs  off  "Media"  "Non-free codecs and MS fonts - NOT FOSS"
install_codecs() {
    # accept the MS fonts license up front so it doesn't stop and ask
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
        | sudo debconf-set-selections
    apt_install ttf-mscorefonts-installer libavcodec-extra gstreamer1.0-libav gstreamer1.0-plugins-ugly
}

# ---------------------------------------------------------------------
app  disks  off  "Disks & backup"  "GNOME Disks"
install_disks() {
    apt_install gnome-disk-utility
}

app  gsmartcontrol  off  "Disks & backup"  "GSmartControl - disk health"
install_gsmartcontrol() {
    apt_install gsmartcontrol
}

app  gparted  off  "Disks & backup"  "GParted - partition editor"
install_gparted() {
    apt_install gparted
}

# ---------------------------------------------------------------------
app  zim  off  "Documents & office"  "Zim - notes (easy checkbox lists)"
install_zim() {
    apt_install zim
}

app  vym  off  "Documents & office"  "VYM - mind mapping"
install_vym() {
    apt_install vym
}

# ---------------------------------------------------------------------
app  evolution  off  "Email & messaging"  "Evolution - email client"
install_evolution() {
    apt_install evolution
}

app  thunderbird  off  "Email & messaging"  "Thunderbird - email client"
install_thunderbird() {
    apt_install thunderbird
}

app  neomutt  off  "Email & messaging"  "NeoMutt - terminal email client"
install_neomutt() {
    apt_install neomutt
}

# ---------------------------------------------------------------------
app  gimp  off  "Media"  "GIMP - image editor (like Photoshop)"
install_gimp() {
    apt_install gimp
}

app  pinta  off  "Media"  "Pinta - simple image editor (like MS Paint)"
install_pinta() {
    flatpak_install com.github.PintaProject.Pinta
}

# ---------------------------------------------------------------------
app  timeshift  off  "Disks & backup"  "Timeshift - system snapshots"
install_timeshift() {
    apt_install timeshift
}

app  duplicity  off  "Disks & backup"  "Duplicity - encrypted cloud backup (CLI)"
install_duplicity() {
    apt_install duplicity
}

# ---------------------------------------------------------------------
app  anydesk  off  "Remote & network"  "AnyDesk - remote desktop - NOT FOSS"
install_anydesk() {
    curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
        | sudo gpg --dearmor --yes -o /usr/share/keyrings/anydesk.gpg
    echo "deb [signed-by=/usr/share/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" \
        | sudo tee /etc/apt/sources.list.d/anydesk.list
    sudo apt-get update
    apt_install anydesk
    # disable the anydesk tray icon
    sudo rm -f /etc/xdg/autostart/anydesk_global_tray.desktop
}

app  teamviewer  off  "Remote & network"  "TeamViewer - remote desktop - NOT FOSS"
install_teamviewer() {
    cd /tmp || return 1
    curl -fsSLo teamviewer_amd64.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    apt_install ./teamviewer_amd64.deb
    rm -f teamviewer_amd64.deb
}

# ---------------------------------------------------------------------
app  ftp_server  off  "Remote & network"  "vsftpd - FTP server (best on a server)"
install_ftp_server() {
    apt_install vsftpd
    # open the FTP ports if the firewall is installed
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow OpenSSH
        sudo ufw allow 20:21/tcp
        sudo ufw allow 20000:25000/tcp
    fi
}

app  midnight_commander  off  "Terminal tools"  "Midnight Commander - file manager / FTP client"
install_midnight_commander() {
    apt_install mc
}

# ---------------------------------------------------------------------
VERACRYPT_VERSION="1.26.24"

app  veracrypt_cli  off  "Security & privacy"  "VeraCrypt (terminal)"
install_veracrypt_cli() {
    install_veracrypt_deb "veracrypt-console-${VERACRYPT_VERSION}-Debian-13-amd64.deb"
}

app  veracrypt_gui  off  "Security & privacy"  "VeraCrypt (graphical)"
install_veracrypt_gui() {
    install_veracrypt_deb "veracrypt-${VERACRYPT_VERSION}-Debian-13-amd64.deb"
}

# helper for the two VeraCrypt entries: download, check the signature, install
install_veracrypt_deb() {
    local deb="$1"
    local base="https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download"
    cd /tmp || return 1
    curl -fsSLo "$deb"     "$base/$deb"
    curl -fsSLo "$deb.sig" "$base/$deb.sig"
    curl -fsSLo VeraCrypt_PGP_public_key.asc https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc
    gpg --show-keys VeraCrypt_PGP_public_key.asc
    gpg --import VeraCrypt_PGP_public_key.asc
    gpg --verify "$deb.sig" "$deb"
    apt_install "./$deb"
}

# ---------------------------------------------------------------------
app  kleopatra  off  "Security & privacy"  "Kleopatra - GPG key manager"
install_kleopatra() {
    apt_install kleopatra
}

# KeePassXC keeps passwords in a local file only (no syncing built in)
app  keepassxc  off  "Security & privacy"  "KeePassXC - password manager (local)"
install_keepassxc() {
    apt_install keepassxc
}

app  bitwarden  off  "Security & privacy"  "Bitwarden - password manager (cloud sync) - NOT FOSS"
install_bitwarden() {
    flatpak_install com.bitwarden.desktop
}

app  authenticator  off  "Security & privacy"  "GNOME Authenticator - 2FA codes"
install_authenticator() {
    flatpak_install com.belmoussaoui.Authenticator
}

app  authpass  off  "Security & privacy"  "AuthPass - password manager"
install_authpass() {
    flatpak_install app.authpass.AuthPass
}

app  pass  off  "Security & privacy"  "pass - terminal password store (+ OTP)"
install_pass() {
    apt_install pass pass-extension-otp
}

app  yubikey_manager  off  "Security & privacy"  "YubiKey Manager"
install_yubikey_manager() {
    apt_install yubikey-manager yubikey-manager-qt
}

app  yubico_authenticator  off  "Security & privacy"  "Yubico Authenticator + smart card service"
install_yubico_authenticator() {
    flatpak_install com.yubico.yubioath
    apt_install pcscd libpcsclite1
    sudo systemctl enable --now pcscd
}

# ---------------------------------------------------------------------
app  kdeconnect  off  "Remote & network"  "KDE Connect - link your phone"
install_kdeconnect() {
    apt_install kdeconnect
    # dark theme for KDE applets
    bash "$REPO_DIR/kdeTheme.sh"
    # disable kwallet (Brave is annoying when it is active)
    local svc
    for svc in /usr/share/dbus-1/services/org.kde.kwalletd6.service \
               /usr/share/dbus-1/services/org.kde.kwalletd5.service; do
        if [ -e "$svc" ]; then
            sudo mv "$svc" "$svc.disabled"
        fi
    done
}

# ---------------------------------------------------------------------
app  transmission  off  "Remote & network"  "Transmission - torrent client"
install_transmission() {
    apt_install transmission
}

# ---------------------------------------------------------------------
app  signal  off  "Email & messaging"  "Signal - encrypted messaging"
install_signal() {
    curl -fsSL https://updates.signal.org/desktop/apt/keys.asc \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' \
        | sudo tee /etc/apt/sources.list.d/signal-xenial.list
    sudo apt-get update
    apt_install signal-desktop
}

# ---------------------------------------------------------------------
app  screen_recorder  off  "Media"  "SimpleScreenRecorder"
install_screen_recorder() {
    apt_install simplescreenrecorder
}

app  kdenlive  off  "Media"  "Kdenlive - video editor"
install_kdenlive() {
    apt_install kdenlive
}

app  shotcut  off  "Media"  "Shotcut - video editor"
install_shotcut() {
    apt_install shotcut
}

app  ffmpeg  off  "Media"  "FFmpeg - video converter (CLI)"
install_ffmpeg() {
    apt_install ffmpeg
}

app  handbrake  off  "Media"  "HandBrake - video converter"
install_handbrake() {
    apt_install handbrake
}

app  freetube  off  "Media"  "FreeTube - private YouTube front end"
install_freetube() {
    flatpak_install io.freetubeapp.FreeTube
}

# ---------------------------------------------------------------------
app  steam  off  "Other"  "Steam - gaming - NOT FOSS"
install_steam() {
    sudo dpkg --add-architecture i386
    sudo apt-get update
    apt_install steam-installer
}

# ---------------------------------------------------------------------
app  tealdeer  off  "Terminal tools"  "tealdeer - simplified man pages (tldr)"
install_tealdeer() {
    apt_install tealdeer
}

# ---------------------------------------------------------------------
app  vscode  off  "Development"  "VS Code - NOT FOSS"
install_vscode() {
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /usr/share/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt-get update
    apt_install code
}

app  vscodium  off  "Development"  "VSCodium - open source build of VS Code"
install_vscodium() {
    curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
        | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt-get update
    apt_install codium
}

# unofficial community repo wrapping JetBrains' tarball - not published by JetBrains
app  pycharm  off  "Development"  "PyCharm (community repo)"
install_pycharm() {
    curl -fsSL https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" \
        | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null
    sudo apt-get update
    apt_install pycharm
}

# ---------------------------------------------------------------------
# NordVPN: i3 keybinds, autostart and scripts are already included
app  nordvpn  off  "Remote & network"  "NordVPN (keybinds included) - NOT FOSS"
install_nordvpn() {
    curl -fsSLo /tmp/nordvpn_install.sh https://downloads.nordcdn.com/apps/linux/install.sh
    sh /tmp/nordvpn_install.sh -n
    sudo usermod -aG nordvpn "$USER"
}

# Mullvad VPN: i3 keybinds, autostart and scripts are NOT included yet
app  mullvad_vpn  off  "Remote & network"  "Mullvad VPN (no keybinds yet) - NOT FOSS"
install_mullvad_vpn() {
    add_mullvad_repo
    apt_install mullvad-vpn
}

# shared by Mullvad Browser and Mullvad VPN
add_mullvad_repo() {
    sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable stable main" \
        | sudo tee /etc/apt/sources.list.d/mullvad.list
    sudo apt-get update
}

# ---------------------------------------------------------------------
# GnuCash isn't offered here: it has no dark/light theming of its own and
# ignores the system GTK theme, so it always shows up stark white regardless
# of everything else copyconf.sh sets up. HomeBank (below) does respect it.
app  homebank  off  "Other"  "HomeBank - simple budget tracker"
install_homebank() {
    flatpak_install fr.free.Homebank
}

# ---------------------------------------------------------------------
app  postman  off  "Development"  "Postman API platform (flatpak) - NOT FOSS"
install_postman() {
    flatpak_install com.getpostman.Postman
}

app  postman_cli  off  "Development"  "Postman CLI - NOT FOSS"
install_postman_cli() {
    curl -fsSL "https://dl-cli.pstmn.io/install/linux64.sh" | sh
}

# ---------------------------------------------------------------------
# BleachBit, plus a "BleachBit (Root)" launcher for Rofi that asks for
# your password through polkit
app  bleachbit  off  "Security & privacy"  "BleachBit - file shredder / cleaner"
install_bleachbit() {
    apt_install bleachbit
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

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

# ---------------------------------------------------------------------
app  mat2  off  "Security & privacy"  "mat2 - remove file metadata (CLI)"
install_mat2() {
    apt_install mat2
}

app  metadata_cleaner  off  "Security & privacy"  "Metadata Cleaner - remove file metadata"
install_metadata_cleaner() {
    apt_install metadata-cleaner
}

# ---------------------------------------------------------------------
app  android_tools  off  "Development"  "Android tools - adb, fastboot (for flashing ROMs)"
install_android_tools() {
    apt_install android-sdk-platform-tools-common adb fastboot
}

# ---------------------------------------------------------------------
# Offline Wikipedia, StackExchange dumps, etc. (.zim files)
app  kiwix  off  "Other"  "Kiwix - offline Wikipedia reader"
install_kiwix() {
    apt_install kiwix
}

# serve with:  kiwix-serve --port 8080 /path/to/your.zim  then browse to http://localhost:8080
app  kiwix_tools  off  "Other"  "Kiwix tools - offline content server (CLI)"
install_kiwix_tools() {
    apt_install kiwix-tools
}

# ---------------------------------------------------------------------
# Clipboard sharing and display resizing when running as a KVM/QEMU guest.
# Ticked automatically when the installer detects a KVM/QEMU VM.
app  spice_guest  kvm  "System"  "SPICE guest agent (for KVM/QEMU virtual machines)"
install_spice_guest() {
    apt_install spice-vdagent
}

# Ticked automatically when the installer detects a VirtualBox VM.
# Gives clipboard sharing, shared folders and better display resizing.
# VirtualBox isn't in Debian's normal stable repos - it comes from Debian's
# official Fasttrack repo (fasttrack.debian.net), which this adds.
app  virtualbox_guest  virtualbox  "System"  "VirtualBox Guest Additions (for VirtualBox virtual machines)"
install_virtualbox_guest() {
    apt_install fasttrack-archive-keyring
    . /etc/os-release

    # Fasttrack packages can depend on backports, so make sure backports is on
    if ! grep -rqs -- "${VERSION_CODENAME}-backports" /etc/apt/sources.list /etc/apt/sources.list.d/; then
        sudo tee /etc/apt/sources.list.d/backports.sources > /dev/null <<EOF
Types: deb
URIs: http://deb.debian.org/debian
Suites: ${VERSION_CODENAME}-backports
Components: main contrib
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
    fi

    sudo tee /etc/apt/sources.list.d/fasttrack.sources > /dev/null <<EOF
Types: deb
URIs: https://fasttrack.debian.net/debian-fasttrack
Suites: ${VERSION_CODENAME}-fasttrack ${VERSION_CODENAME}-backports-staging
Components: main contrib
Signed-By: /usr/share/keyrings/fasttrack-archive-keyring.gpg
EOF

    # if the repo can't be reached, take it back out so later apt steps still work
    if ! sudo apt-get update; then
        sudo rm -f /etc/apt/sources.list.d/fasttrack.sources
        sudo apt-get update || true
        return 1
    fi

    apt_install virtualbox-guest-x11

    # lets you open VirtualBox shared folders (takes effect after a reboot)
    if getent group vboxsf > /dev/null; then
        sudo usermod -aG vboxsf "$USER"
    fi
}

# Xen has no equivalent guest-tools package in Debian's own repos:
# - XenServer/Citrix Hypervisor guests want "xe-guest-utilities", which only
#   comes from the vendor, not apt.
# - Plain upstream Xen (PV or HVM) already has what it needs in the kernel;
#   there is nothing extra to install.
# So there's no Xen entry here to tick - only the i3 display config
# (see copyconf.sh) adjusts itself automatically for a Xen guest.

# ---------------------------------------------------------------------
app  podman  off  "Virtualization"  "Podman - containers"
install_podman() {
    apt_install podman
}

# log out and back in (or reboot) for the docker group to take effect
app  docker  off  "Virtualization"  "Docker - containers"
install_docker() {
    apt_install docker.io
    sudo usermod -aG docker "$USER"
}

app  distrobox  off  "Virtualization"  "Distrobox - other distros in containers"
install_distrobox() {
    apt_install distrobox
}

# Cockpit console at https://127.0.0.1:9090/
# log out and back in (or reboot) for the group changes to take effect
app  kvm  off  "Virtualization"  "KVM/QEMU + virt-manager + Cockpit machines"
install_kvm() {
    apt_install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils \
                virt-manager cockpit-machines cockpit-podman distrobox
    sudo systemctl enable --now libvirtd
    sudo usermod -aG libvirt "$USER"
    sudo usermod -aG kvm "$USER"
}

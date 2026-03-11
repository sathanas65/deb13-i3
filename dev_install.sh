#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"
source "$REPO_DIR/install_functions.sh"

## ALL INSTANCES OF "##" BELOW ARE COMMENTS AND REMOVING "##" FROM THE
## LINE WILL BREAK THIS SCRIPT.

## ALL INSTANCES OF A SINGLE "#" FOLLOWED BY TEXT WITH NO SPACE ARE 
## DISABLED APP INSTALLS THAT MAY BE ENABLED BY REMOVING "#".

## ALL INSTANCES OF TEXT WITH NO PRECEDING "#" ARE ENABLED NY DEFAULT.
## APP INSTALLS MAY BE DISABLED BY ADDING A PRECEDING "#", HOWEVER,
## DOING SO MAY BREAK FUNCTION OF CERTAIN FEATURES. IF YOU KNOW WHAT YOU
## ARE DOING THEN GO FOR IT.

## Enable non free repos (required for certain packages)
enable_nonfree

## Flatpak containerized apps platform (required to install flatpak apps)
install_flatpak

## Snap containerized apps platform (required to install snap apps)
#install_snap

## GUI file managers
sudo apt-get install -y nemo
#sudo apt-get install -y thunar
#sudo apt-get install -y nautilus

## audio editor
#sudo apt-get install -y audacity

## terminal apps  
#sudo apt-get install -y htop glances figlet calc

## gui system monitor
sudo apt-get install -y gnome-system-monitor

## GUI apt-get package manager front end
#sudo apt-get install -y synaptic

## printer support
#install_cups

## bluetooth support
#install_bt

## document viewer
sudo apt-get install -y evince

## ebook reader
#sudo apt-get install -y foliate

## comic reader
#sudo apt-get install -y mcomix

## privacy browsers
install_apt_brave
install_flatpak_brave
#install_librewolf
#install_mullvad
#install_tor

## other browsers
## Chromium is required for keybind Super + F1 to open nordvpn login page. 
## Or you can edit ~/scripts/nordlogin.sh to use another browser but nord 
## login script fails in Brave and Librewolf, even with shields down.
sudo apt-get install -y chromium
#sudo apt-get install -y firefox-esr

## dangerzone - Take potentially dangerous PDFs, office documents, or images 
## and convert them to safe PDFs.Dangerzone destroys malware by rendering 
## your document into pixels in a secure sandbox and reconstructing it 
## locally as a PDF. Documents are sanitized in a sandbox with no network
## access, so if a malicious document can compromise one, it can't let anyone know.

#install_dangerzone

## image viewer
sudo apt-get install -y mirage

## GUI text editor Geany
install_geany

## cockpit (admin web console)
## You can access cockpit console from browser at https://127.0.0.1:9090/
sudo apt-get install -y cockpit

## office apps
sudo apt-get install -y libreoffice

## GUI display manager
sudo apt-get install -y arandr

## media player
sudo apt-get install -y vlc 

## media codecs
install_codecs

## GUI disk manager
sudo apt-get install -y gnome-disk-utility 

## GUI disk diagnostics
#sudo apt-get install -y gsmartcontrol 

## GUI partition manager
#sudo apt-get install -y gparted

## GUI clipboard manager
sudo apt-get install -y copyq

## GUI notes manager
#sudo apt-get install -y zim

## mind mapping
#sudo apt-get install -y vym

## GUI email clients

#sudo apt-get install -y evolution
#sudo apt-get install -y thunderbird

## CLI email client
#sudo apt-get install -y neomutt

## screenshots support
sudo apt-get install -y maim xclip xdotool jq

## image editors (gimp is like Adobe Photoshop and pinta is like MS Paint)

#sudo apt-get install -y gimp
#sudo snap install pinta

## GUI backup manager (front end for rsync)
#sudo apt-get install -y timeshift

## duplicity - great CLI for cloud backup - supported by backblaze B2
#sudo apt-get install -y duplicity

## remote clients

#install_anydesk
#install_teamviewer

## ftp client (midnight commander)
#sudo apt-get install -y mc

## veracrypt CLI
#install_veracrypt_cli

## veracrypt GUI
#install_veracrypt_gui

## GUI gpg encryption manager
#sudo apt-get install -y kleopatra

## GUI password managers

#sudo apt-get install -y keepassxc
#sudo snap install bitwarden

## GUI Authentication app
#sudo snap install authpass

## Yubikey app
#sudo apt-get install -y yubikey-manager yubikey-manager-qt

## Smart phone connectivity (link your phone with your Linux PC)
#install_kdeconnect

## GUI torrent client
#sudo apt-get install -y transmission

## signal encrypted messaging (requires the app to be installed on phone first)
#install_signal

## screen recorders

#sudo apt-get install -y simplescreenrecorder
#sudo apt-get install -y kazam

## video editors

#sudo apt-get install -y kdenlive
#sudo apt-get install -y shotcut

## CLI video converter
#sudo apt-get install -y ffmpeg

## GUI video converter
#sudo apt-get install -y handbrake

## YouTube front end
#flatpak install -y flathub io.freetubeapp.FreeTube

## Gaming
#install_steam

## simplified man pages
#sudo apt-get install -y tealdeer

## dev tools

#install_vscode
#install_vscodium
#install_pycharm
#sudo snap install postman
#curl -o- "https://dl-cli.pstmn.io/install/linux64.sh" | sh

## VPNs

#install_nordvpn
#install_mullvadvpn

## personal finance - Denaro
#flatpak install -y flathub org.nickvision.money

## bleachbit file shredder
#install_bleachbit

## CLI metadata removal
#sudo apt-get install -y mat2

## GUI metadata removal
#sudo apt-get install -y metadata-cleaner

## android tools (used when flashing roms)
#sudo apt-get install -y android-sdk-platform-tools-common adb fastboot

## GTK desktop reader for .zim offline content- Wikipedia, StackExchange dumps, etc.
#sudo apt-get install -y kiwix
## CLI tools and server
#sudo apt-get install -y kiwix-tools

## kvm/qemu guest agent  YOU WANT THIS IF installing as kvm-qemu guest vm
#sudo apt-get install -y spice-vdagent 

## container tools

#sudo apt-get install -y podman
#sudo apt-get install -y docker.io
#sudo apt-get install -y distrobox

## KVM/qemu/libvirt hypervisor
#install_virt_manager






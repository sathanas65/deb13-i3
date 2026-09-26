#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Log debugging info
LOG_FILE="/tmp/smb_debug.log"
exec >> "$LOG_FILE" 2>&1
echo "Script started at $(date)"

# Extract the tmux session name to decide which command to run
session_name=$(tmux display-message -p '#S')

# Function to ask for password and run sudo -v
ask_for_password() {
    yad --entry --title="Authentication Required" --text="Enter password for $session_name:" \
        --button=gtk-ok:0 --width=300 --height=100 --center \
        --undecorated --on-top --skip-taskbar --skip-pager --hide-text | sudo -S -v

    # Check if the sudo credential update was successful
    if [ $? -ne 0 ]; then
        notify-send "Session: $session_name" "Authentication failed. Exiting." -u critical
        echo "Authentication failed for $session_name."
        tmux kill-session -t "$session_name"
        exit 1
    fi
}

case "$session_name" in
    unmount_smb)
        ask_for_password
        if sudo umount /mnt/smb_share; then
            notify-send "SMB Unmount" "Successfully unmounted /mnt/smb_share." -u normal
            echo "Successfully unmounted /mnt/smb_share."
        else
            notify-send "SMB Unmount" "Failed to unmount /mnt/smb_share." -u critical
            echo "Failed to unmount /mnt/smb_share."
        fi
        ;;
    shutdown)
        ask_for_password
        sudo shutdown now
        ;;
	reboot)
        ask_for_password
        sudo reboot now
        ;;
    sudo_thunar)
        ask_for_password
        sudo thunar
        ;;
    synaptic)
        ask_for_password
        sudo synaptic
        ;;
    timeshift)
        ask_for_password
        sudo timeshift-gtk
        ;;
    sudo_disks)
        ask_for_password
        sudo gnome-disks
        ;;
    xconfig)
        terminator -x sh -c 'sudo cp /etc/X11/xorg.conf /etc/X11/xorg.conf.bkp && sudo nano /etc/X11/xorg.conf; exec bash'
        ;;
    grubconfig)
        terminator -x sh -c 'sudo cp /etc/default/grub /etc/default/grub.bkp && sudo nano /etc/default/grub; exec bash'
        ;;
    fstab)
        terminator -x sh -c 'sudo cp /etc/fstab /etc/fstab.bkp && sudo nano /etc/fstab; exec bash'
        ;;
    crypttab)
        terminator -x sh -c 'sudo cp /etc/crypttab /etc/crypttab.bkp && sudo nano /etc/crypttab; exec bash'
        ;;
    sudoers)
        terminator -x sh -c 'sudo cp /etc/sudoers /etc/sudoers.bkp && sudo nano /etc/sudoers; exec bash'
        ;;
    ldmconfig)
        terminator -x sh -c 'sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.bkp && sudo nano /etc/lightdm/lightdm.conf; exec bash'
        ;;
    ldmgreetconfig)
        terminator -x sh -c 'sudo cp /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf.bkp && sudo nano /usr/share/lightdm/lightdm-gtk-greeter.conf.d/01_debian.conf; exec bash'
        ;;
    ldmdisplay)
        terminator -x sh -c 'sudo cp /usr/share/display.sh /usr/share/display.sh.bkp && sudo nano /usr/share/display.sh; exec bash'
        ;;
    interfaces)
        terminator -x sh -c 'sudo cp /etc/network/interfaces /etc/network/interfaces.bkp && sudo nano /etc/network/interfaces; exec bash'
        ;;
    networks)
        terminator -x sh -c 'sudo cp /etc/networks /etc/networks.bkp && sudo nano /etc/networks; exec bash'
        ;;
    netmanage)
        terminator -x sh -c 'sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bkp && sudo nano /etc/NetworkManager/NetworkManager.conf; exec bash'
        ;;
    *)
        notify-send "Session: $session_name" "Unknown session action: $session_name" -u critical
        echo "Unknown session action: $session_name."
        exit 1
        ;;
esac

exit 0

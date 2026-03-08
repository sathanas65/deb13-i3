#!/bin/bash

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Extract the tmux session name to decide which command to run
session_name=$(tmux display-message -p '#S' 2>/dev/null)

case "$session_name" in
    norddouble)
        connect_output=$(nordvpn connect double vpn 2>&1)
        connect_exit_status=$?

        killswitch_output=$(nordvpn set killswitch enabled 2>&1)
        killswitch_exit_status=$?

        notify-send "Nord Double VPN Connection" "$connect_output - Exit Status: $connect_exit_status"
        notify-send "Nord Double VPN Killswitch" "$killswitch_output - Exit Status: $killswitch_exit_status"
        ;;
    nordlogin)
        output=$(nordvpn login 2>&1)

        url=$(echo "$output" | grep -o 'https://[a-zA-Z0-9./?=_-]*')

        if [ -n "$url" ]; then
            chromium "$url" &>/dev/null &
            notify-send "NordVPN Login" "Opened login URL in Chromium."
        else
            notify-send "NordVPN Login" "Login URL not found."
            exit 1
        fi
        ;;
    nordpause)
        killswitch_output=$(nordvpn set killswitch disabled 2>&1)
        killswitch_exit_status=$?

        disconnect_output=$(nordvpn disconnect 2>&1)
        disconnect_exit_status=$?

        notify-send "NordVPN Pause" "$killswitch_output - Exit Status: $killswitch_exit_status"
        notify-send "NordVPN Pause" "$disconnect_output - Exit Status: $disconnect_exit_status"
        ;;
    nordresume)
        connect_output=$(nordvpn connect 2>&1)
        connect_exit_status=$?

        killswitch_output=$(nordvpn set killswitch enabled 2>&1)
        killswitch_exit_status=$?

        notify-send "NordVPN Resume" "$connect_output - Exit Status: $connect_exit_status"
        notify-send "NordVPN Resume" "$killswitch_output - Exit Status: $killswitch_exit_status"
        ;;
    nordpnp)
        connect_output=$(nordvpn connect p2p 2>&1)
        connect_exit_status=$?

        killswitch_output=$(nordvpn set killswitch enabled 2>&1)
        killswitch_exit_status=$?

        notify-send "NordVPN P2P" "$connect_output - Exit Status: $connect_exit_status"
        notify-send "NordVPN P2P" "$killswitch_output - Exit Status: $killswitch_exit_status"
        ;;
    nordstatus)
        status_output=$(nordvpn status 2>&1)
        status_exit_status=$?

        notify-send "NordVPN Status" "$status_output"
        exit $status_exit_status
        ;;
    *)
        notify-send "NordVPN Script" "Invalid tmux session name: $session_name"
        exit 1
        ;;
esac

exit 0

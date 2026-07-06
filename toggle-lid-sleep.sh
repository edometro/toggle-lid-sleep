#!/bin/bash

# toggle-lid-sleep
# A tool to easily toggle laptop lid sleep behavior on systemd Linux distributions.

LOGIND_CONF="/etc/systemd/logind.conf"

show_help() {
    echo "Usage: toggle-lid-sleep [status|on|off|toggle]"
    echo ""
    echo "Commands:"
    echo "  status  - Show current lid switch behavior"
    echo "  on      - Enable sleep when lid is closed (suspend)"
    echo "  off     - Disable sleep when lid is closed (ignore)"
    echo "  toggle  - Toggle between on and off states"
    echo ""
    echo "Note: Changing state requires sudo privileges."
}

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This command requires root privileges. Please run with sudo."
        exit 1
    fi
}

get_status() {
    if grep -q "^HandleLidSwitch=ignore" "$LOGIND_CONF"; then
        echo "ignore"
    elif grep -q "^HandleLidSwitch=suspend" "$LOGIND_CONF"; then
        echo "suspend"
    else
        # If not explicitly set or commented out, default is usually suspend
        echo "suspend (default/commented)"
    fi
}

print_status() {
    local status
    status=$(get_status)
    if [[ "$status" == "ignore" ]]; then
        echo "Current status: OFF (Lid close is ignored - laptop stays awake)"
    else
        echo "Current status: ON (Lid close will suspend the laptop)"
    fi
}

apply_change() {
    echo "Restarting systemd-logind service to apply changes..."
    systemctl restart systemd-logind
    echo "Done."
}

set_on() {
    check_sudo
    echo "Enabling lid sleep (setting HandleLidSwitch=suspend)..."
    if grep -q "^#\?HandleLidSwitch=" "$LOGIND_CONF"; then
        sed -i 's/^#\?HandleLidSwitch=.*/HandleLidSwitch=suspend/' "$LOGIND_CONF"
    else
        echo "HandleLidSwitch=suspend" >> "$LOGIND_CONF"
    fi
    apply_change
}

set_off() {
    check_sudo
    echo "Disabling lid sleep (setting HandleLidSwitch=ignore)..."
    if grep -q "^#\?HandleLidSwitch=" "$LOGIND_CONF"; then
        sed -i 's/^#\?HandleLidSwitch=.*/HandleLidSwitch=ignore/' "$LOGIND_CONF"
    else
        echo "HandleLidSwitch=ignore" >> "$LOGIND_CONF"
    fi
    apply_change
}

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1

case "$COMMAND" in
    status)
        print_status
        ;;
    on)
        set_on
        ;;
    off)
        set_off
        ;;
    toggle)
        check_sudo
        current=$(get_status)
        if [[ "$current" == "ignore" ]]; then
            set_on
        else
            set_off
        fi
        ;;
    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
